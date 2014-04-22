From: Erik Hugne <erik.hugne@ericsson.com>
Subject: skb_try_coalesce bug?
Date: Tue, 22 Apr 2014 14:01:25 +0200
Message-ID: <20140422120125.GC7019@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:48807 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755707AbaDVMB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 08:01:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that if the head skb of a reassembly chain have enough tailroom
to hold the data of a received fragment, skb_try_coalesce() will append this
directly to the head, even if preceding fragments have been put on a frag list.
This will cause a corrupted buffer to be passed to userland when 
skb_copy_datagram_iovec() later copies the contents of head, and then each frag
one by one to the target iovec.
 
Is skb_try_coalesce() broken, or are we using it wrongly in tipc?

//E
