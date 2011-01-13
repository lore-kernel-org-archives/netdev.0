From: Anand Raj Manickam <anandrm@gmail.com>
Subject: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Thu, 13 Jan 2011 20:10:44 +0530
Message-ID: <AANLkTi=qVSEh=RyzJ6y4kQvJW+hxqWMh2gAMmhk7GGob@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59835 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756656Ab1AMOkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 09:40:45 -0500
Received: by bwz15 with SMTP id 15so1576819bwz.19
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 06:40:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi ,
I have a problem on Realtek 8168C chipset - r8169 Driver .
The VLAN tag on Tx  & Rx gets stripped .

The 8021q module is loaded .
vconfig add eth0 50
ifconfig eth0.50 172.16.1.10 up

ping -I eth0.50 172.16.1.1 .

All packets on Tx & Rx have the VLAN tag stripped on Tx & Rx.

On debugging the Driver , we found that on Tx the VLAN tag is present.

static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
{
.
.
tp->tx_skb[entry].len = len;
txd->addr = cpu_to_le64(mapping);
txd->opts2 = cpu_to_le32(rtl8169_tx_vlan_tag(tp, skb));
printk("The Vlan tag %x \n",txd->opts2);
.
.
}

The Vlan tag 23200

In the above value 23200
2 - TxVlanTag
32 - Vlan tag (50).

>From the above we are clear that the Vlan tag reaches the driver .

Can someone shed some light on this issue ?
Any pointer are welcome.
Thanks,
Anand
