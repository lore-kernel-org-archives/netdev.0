From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Wed, 16 Aug 2006 21:30:46 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0608162118580.26987@bizon.gios.gov.pl>
References: <200607311015.40255.Christophe.Devriese@eurid.eu>
 <20060802.135859.91441473.davem@davemloft.net> <200608040101.k7411ZZt013801@death.nxdomain.ibm.com>
 <20060814.170905.69218340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-137179206-1155756646=:26987"
Cc: fubar@us.ibm.com, Christophe.Devriese@eurid.eu,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:178 "EHLO bizon.gios.gov.pl")
	by vger.kernel.org with ESMTP id S932196AbWHPTbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 15:31:24 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060814.170905.69218340.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-137179206-1155756646=:26987
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 14 Aug 2006, David Miller wrote:

> From: Jay Vosburgh <fubar@us.ibm.com>
> Date: Thu, 03 Aug 2006 18:01:35 -0700
>
>> =09In this case (bond0.555 above bond0 above eth0,eth1,etc),
>> skb_bond doesn't suppress duplicates because skb_bond is called with the
>> skb->dev set to the bond0.555 dev, not the ethX dev.  Non-accelerated
>> VLAN devices don't do this; they'll come in with skb->dev set to ethX
>> and will go through skb_bond as expected.
>
> Ok, since __vlan_hwaccel_rx() bypasses the netif_receive_skb()
> that would normally occur, we have to duplicate the bonding
> drop checks.
>
> The submitted patch put skb_bond() into if_vlan.h which is
> definitely the wrong thing to do.  This is a generic operation
> and therefore belongs in linux/netdevice.h at best.
>
> Furthermore, we're only interested in the packet drop check,
> so that's the only part of the logic we need to export,
> the rest can stay private to skb_bond() in net/core/dev.c
>
> Can the folks who can reproduce this try this patch?

Works for me, thank you.

Acked-by: Krzysztof Piotr Oledzki <ole@ans.pl>

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-137179206-1155756646=:26987--
