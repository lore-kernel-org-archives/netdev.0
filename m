From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] af_packet: account for VLAN when checking packet size
Date: Mon, 11 Oct 2010 19:29:32 +0200
Message-ID: <20101011172932.GB12342@orbit.nwl.cc>
References: <20101011131500.GA12342@orbit.nwl.cc>
 <1286803522-16478-1-git-send-email-phil@nwl.cc>
 <1286805782.2737.25.camel@edumazet-laptop>
 <20101011.090153.226774563.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	johann.baudy@gnu-log.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:58493 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755454Ab0JKR3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 13:29:33 -0400
Content-Disposition: inline
In-Reply-To: <20101011.090153.226774563.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 11, 2010 at 09:01:53AM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 11 Oct 2010 16:03:02 +0200
> 
> > If we dont test ETH_P_8021Q protocol here, we allow sending 1504 bytes
> > frames for MTU=1500
> > 
> > Should we really care ?
> > 
> > If not, just do
> > 
> > reserve = dev->hard_header_len + VLAN_HLEN;
> 
> Thats a good point, I think we need to validate the SKB protocol
> field.

Which is set to the value of the passed struct sockaddr_ll field
sll_protocol. At least in the two userspace code samples I have here,
the later field is set to htons(ETH_P_ALL). So unless one changes the
API, the only way to find out the packet type is to actually parse the
given ethernet header.

Since tpacket_rcv() just interprets the vlan_tci skb field, such
detailed packet inspection is otherwise not done in af_packet.c.

Greetings, Phil
