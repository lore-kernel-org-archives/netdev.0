From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] af_packet: account for VLAN when checking packet size
Date: Tue, 12 Oct 2010 19:19:41 +0200
Message-ID: <20101012171940.GB30613@redhat.com>
References: <20101011131500.GA12342@orbit.nwl.cc>
 <1286803522-16478-1-git-send-email-phil@nwl.cc>
 <1286805782.2737.25.camel@edumazet-laptop>
 <20101011.090153.226774563.davem@davemloft.net>
 <20101011172932.GB12342@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, johann.baudy@gnu-log.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48059 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757861Ab0JLR0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Oct 2010 13:26:03 -0400
Content-Disposition: inline
In-Reply-To: <20101011172932.GB12342@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 11, 2010 at 07:29:32PM +0200, Phil Sutter wrote:
> On Mon, Oct 11, 2010 at 09:01:53AM -0700, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Mon, 11 Oct 2010 16:03:02 +0200
> > 
> > > If we dont test ETH_P_8021Q protocol here, we allow sending 1504 bytes
> > > frames for MTU=1500
> > > 
> > > Should we really care ?
> > > 
> > > If not, just do
> > > 
> > > reserve = dev->hard_header_len + VLAN_HLEN;
> > 
> > Thats a good point, I think we need to validate the SKB protocol
> > field.
> 
> Which is set to the value of the passed struct sockaddr_ll field
> sll_protocol. At least in the two userspace code samples I have here,
> the later field is set to htons(ETH_P_ALL). So unless one changes the
> API, the only way to find out the packet type is to actually parse the
> given ethernet header.

Yes, like eth_type_trans does I guess.  I think we had a similar
discussion already:

http://lists.openwall.net/netdev/2010/01/06/38

Summary: if we want to make the protocol field have the correct
value for this case we need to make it work for other
transports not just for ethernet.

> Since tpacket_rcv() just interprets the vlan_tci skb field, such
> detailed packet inspection is otherwise not done in af_packet.c.
> 
> Greetings, Phil
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
