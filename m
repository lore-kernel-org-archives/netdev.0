From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: netlink: filter particular protocols from
 analyzers
Date: Thu, 05 Sep 2013 14:44:42 -0400 (EDT)
Message-ID: <20130905.144442.2085221662776542385.davem@davemloft.net>
References: <1378396127-8342-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkmann@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756868Ab3IESoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 14:44:44 -0400
In-Reply-To: <1378396127-8342-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu,  5 Sep 2013 17:48:47 +0200

> From: Daniel Borkmann <dborkmann@redhat.com>
> 
> Fix finer-grained control and let only a whitelist of allowed netlink
> protocols pass, in our case related to networking. If later on, other
> subsystems decide they want to add their protocol as well to the list
> of allowed protocols they shall simply add it. While at it, we also
> need to tell what protocol is in use otherwise BPF_S_ANC_PROTOCOL can
> not pick it up (as it's not filled out).
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

This takes away functionality that I'd be more interesting in using,
namely being able to listen to all netlink protocols using one tap.

Seriously, when I first saw this feature, that was the first way I'd
imagine myself using it, as a tcpdump for netlink traffic, all of
it.

If I just want to hear all netlink traffic, don't make me be forced to
know every single NETLINK_* protocol value and have to open that many
sockets just to do so.

It also makes it so that I can't listen to userlevel custom netlink
protocols, another minus of filtering.

At the very least, allow an sk_protocol of zero or similar to have this
meaning of "everything".

I'm not applying this patch, sorry.
