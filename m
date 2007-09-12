From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [RFC v2 PATCH 0/2] Add RCU locking to SCTP address management
Date: Wed, 12 Sep 2007 15:46:36 -0400
Message-ID: <11896263983281-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:54055 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764570AbXILTqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 15:46:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok, this is version 2 of the patch that incorporates comments from
Sridhar Samudrala and Paul McKenney.

The changes icorporated are:
 1.  Add locking around the modification of the global sctp_local_addr_list
 when processing the notifiers.  After looking around, it is possible for
 the IPv4 and IPv6 notifiers to be called at the same time, which means that
 we need a spin lock.

 2.  After the Paul's explanation of why writers would would to call
 rcu_read_lock, it's apparent that we really don't need that in our usage.
 I've removed all that I could find and conser safe.

 3. I took Paul's suggestiong of passing an explicit rcu callback when
 removing entries from the list since these can be done it different
 contexts.  This made the removal code rather simple.

Things I've left behind:
 1.  The valid flag remains.  After discussing the virtues with Paul Moore
 (who used the same functionality in Netlabel code), I think that the
 valid flag slightly reduces the possibility that the reader will use
 an entry that's about to be removed.  It's a good thing in our case.
 It doesn't really harm anything if a reader used a !valid entry, but
 I'd like to reduce that chance.

I would appreciate any further comments

Thanks
-vlad
