From: Anand Raj Manickam <anandrm@gmail.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Thu, 13 Jan 2011 20:39:07 +0530
Message-ID: <AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com>
References: <AANLkTi=qVSEh=RyzJ6y4kQvJW+hxqWMh2gAMmhk7GGob@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37829 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757028Ab1AMPJJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 10:09:09 -0500
Received: by bwz15 with SMTP id 15so1606440bwz.19
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 07:09:07 -0800 (PST)
In-Reply-To: <AANLkTi=qVSEh=RyzJ6y4kQvJW+hxqWMh2gAMmhk7GGob@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry,
This happens on a Linux 2.6.30.8 kernel .The driver is  in-kernel.

On Thu, Jan 13, 2011 at 8:10 PM, Anand Raj Manickam <anandrm@gmail.com>=
 wrote:
> Hi ,
> I have a problem on Realtek 8168C chipset - r8169 Driver .
> The VLAN tag on Tx =A0& Rx gets stripped .
>
> The 8021q module is loaded .
> vconfig add eth0 50
> ifconfig eth0.50 172.16.1.10 up
>
> ping -I eth0.50 172.16.1.1 .
>
> All packets on Tx & Rx have the VLAN tag stripped on Tx & Rx.
>
> On debugging the Driver , we found that on Tx the VLAN tag is present=
=2E
>
> static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device =
*dev)
> {
> .
> .
> tp->tx_skb[entry].len =3D len;
> txd->addr =3D cpu_to_le64(mapping);
> txd->opts2 =3D cpu_to_le32(rtl8169_tx_vlan_tag(tp, skb));
> printk("The Vlan tag %x \n",txd->opts2);
> .
> .
> }
>
> The Vlan tag 23200
>
> In the above value 23200
> 2 - TxVlanTag
> 32 - Vlan tag (50).
>
> From the above we are clear that the Vlan tag reaches the driver .
>
> Can someone shed some light on this issue ?
> Any pointers are welcome.
> Thanks,
> Anand
>
