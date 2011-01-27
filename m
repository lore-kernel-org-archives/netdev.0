From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Thu, 27 Jan 2011 17:50:31 +0100
Message-ID: <20110127165031.GA7966@electric-eye.fr.zoreil.com>
References: <AANLkTi=qVSEh=RyzJ6y4kQvJW+hxqWMh2gAMmhk7GGob@mail.gmail.com> <AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com> <20110116192017.GA3569@electric-eye.fr.zoreil.com> <AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com> <AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com> <20110118012146.GA3704@electric-eye.fr.zoreil.com> <AANLkTimA1C=trH+WGpBdPU=vBf-cN+xB4Br3+vJb-Qum@mail.gmail.com> <20110127150744.GA7925@electric-eye.fr.zoreil.com> <AANLkTi=OwsMO8x9AOy=MmohU4SSQcv+o=TvwNs0NNsQR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes <hayeswang@realtek.com>
To: Anand Raj Manickam <anandrm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55657 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104Ab1A0QwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 11:52:15 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTi=OwsMO8x9AOy=MmohU4SSQcv+o=TvwNs0NNsQR@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anand Raj Manickam <anandrm@gmail.com> :
> On Thu, Jan 27, 2011 at 8:37 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> > Anand Raj Manickam <anandrm@gmail.com> :
[...]
> > - ip addr show
> 
> 3: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen 1000
>     link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
>     inet 172.16.1.1/16 brd 172.16.255.255 scope global eth0
>     inet6 fe80::217:54ff:fe00:f662/64 scope link
>        valid_lft forever preferred_lft forever
> 
> 8: eth0.50@eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noqueue
>     link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
>     inet 172.16.10.10/24 brd 172.16.10.255 scope global eth0.50
>     inet6 fe80::217:54ff:fe00:f662/64 scope link
>        valid_lft forever preferred_lft forever

Could you try again after issuing :

ip addr del 172.16.1.1/16 brd 172.16.255.255 dev eth0

then send the unabbreviated "ip addr show" and "ip route show all" if
things do not perform better.

(no iptables / ip rules wizardry, right ?)

[...]
> > - ethtool -k eth0
> 
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: off
> scatter-gather: off
> tcp segmentation offload: off
> udp fragmentation offload: off
> generic segmentation offload: off

Ok.

[...]
> > I do not get the "VLAN tag gets stripped" concept, especially on Tx.
> > Does it mean "no packet" or "a packet whose content is wrong" ?
> 
> Sorry for not being clear ;-)
> 
> When we transmit a packet with VLAN TAG , the TAG get stripped when
> transmitted through the device , the other end trunk port / sniffer
> does NOT see a TAG.
> Similarly , when a VLAN Tagged packet is sent from the other end , The
> TAG gets stripped by the device , We DONOT see the tag .

But the data flows in both directions, right ?

> I use tcpdump -i eth0 -n -nn -e vlan 50
> to see if the packets are gettin tagged or NOT .
> 
> The same config works on forcedeth

What do you call "same config" ?

I am mildly convinced that your config is simple enough to isolate a
driver level vlan problem.

-- 
Ueimor
