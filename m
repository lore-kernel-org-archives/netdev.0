From: Phil Sutter <phil@nwl.cc>
Subject: Re: sending VLAN packets via packet_mmap
Date: Mon, 11 Oct 2010 15:15:00 +0200
Message-ID: <20101011131500.GA12342@orbit.nwl.cc>
References: <20100930192414.GD26509@orbit.nwl.cc>
 <20101006.235343.98903661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, johann.baudy@gnu-log.net,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:58107 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754562Ab0JKNPC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 09:15:02 -0400
Content-Disposition: inline
In-Reply-To: <20101006.235343.98903661.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

On Wed, Oct 06, 2010 at 11:53:43PM -0700, David Miller wrote:
> From: Phil Sutter <phil@nwl.cc>
> Date: Thu, 30 Sep 2010 21:24:14 +0200
> 
> > The actual problem in tpacket_snd() is this:
> > 
> > | reserve = dev->hard_header_len;
> > | [...]
> > | if (size_max > dev->mtu + reserve)
> > | 	size_max = dev->mtu + reserve;
> > 
> > I guess the check is there to avoid skb overflows on malicious data
> > input. Is this correct? Are there other reasons for it's existence?
> 
> We can add a special allowance of 4 extra bytes in this size check
> _iff_ the device is ethernet and the NETIF_F_VLAN_CHALLENGED netdev
> feature bit is not set.

Making sure the device can actually handle the additional data, good
point!

Perhaps a bit philosophical, but what about NETIF_F_HW_VLAN_TX? AFAICT,
NICs providing that feature insert the VLAN header themselfs, correct?
Therefore __vlan_hwaccel_put_tag() just sets skb->vlan_tci. In order to
make use of that feature, one could always insert the VLAN header in the
kernel using vlan_put_tag(), depending on tpacket2_hdr.tp_vlan_tci
(probably in combination with VLAN_TAG_PRESENT to allow for VLAN ID 0).

Resumptively speaking, I'm probably talking about another feature
instead of solution for the bug in first place so I'll reply to this
mail with a patch implementing the suggested solution.

Greetings, Phil
