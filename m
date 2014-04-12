From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: preserve netlink pkt_type on
 dev_queue_xmit_nit
Date: Sat, 12 Apr 2014 17:02:05 -0400 (EDT)
Message-ID: <20140412.170205.763190722974019268.davem@davemloft.net>
References: <1397240729-32667-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darkjames-ws@darkjames.pl
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756223AbaDLVCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 17:02:07 -0400
In-Reply-To: <1397240729-32667-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 11 Apr 2014 20:25:29 +0200

> In dev_queue_xmit_nit(), we unconditionally overwrite
> the pkt_type of the new skb clone to PACKET_OUTGOING,
> thus in packet sockets, we always propagate this to
> sll_pkttype member of struct sockaddr_ll.
> 
> Hence, probe for skb_nit_type_netlink() and in case
> we tap on a non-netlink socket, overwrite the setting
> to PACKET_OUTGOING just as before. I think we can mark
> the _non_-netlink sockets as likely since i) we don't
> expect such heavy load in netlink messages as we do
> with network packets, and ii) tapping on netlink
> messages is rather to be considered a rare event
> compared to tapping on network packets.
> 
> I have tested this with capturing on latest netsniff-ng
> and propagation works fine. While at it, we also fixed
> up the comment style and added two cases where their
> conditions are to be considered unlikely() as well.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

I really don't like the idea of treating some packets that go out of
dev_queue_xmit_nit() as one type, and others of another type.

Because dammit, if the packet is going through this function it very
much is PACKET_OUTGOING.

It's outgoing to your special netlink tap device in this case right?

Sorry, I really don't want to apply this patch, and you haven't even
stated 1) what problem this actually causes and 2) why you cannot deal
around it in userspace.
