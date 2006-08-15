From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Tue, 15 Aug 2006 15:18:13 -0700
Message-ID: <200608152218.k7FMIDZt009900@death.nxdomain.ibm.com>
References: <200607311015.40255.Christophe.Devriese@eurid.eu> <20060802.135859.91441473.davem@davemloft.net> <200608040101.k7411ZZt013801@death.nxdomain.ibm.com> <20060814.170905.69218340.davem@davemloft.net>
Cc: Christophe.Devriese@eurid.eu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:30140 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750750AbWHOWSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 18:18:17 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7FMIGeE031063
	for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 18:18:16 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7FMIGVp165768
	for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 18:18:16 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7FMIF7p009398
	for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 18:18:16 -0400
To: David Miller <davem@davemloft.net>
In-reply-to: <20060814.170905.69218340.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
[...]
>Ok, since __vlan_hwaccel_rx() bypasses the netif_receive_skb()
>that would normally occur, we have to duplicate the bonding
>drop checks.
>
>The submitted patch put skb_bond() into if_vlan.h which is
>definitely the wrong thing to do.  This is a generic operation
>and therefore belongs in linux/netdevice.h at best.
>
>Furthermore, we're only interested in the packet drop check,
>so that's the only part of the logic we need to export,
>the rest can stay private to skb_bond() in net/core/dev.c
>
>Can the folks who can reproduce this try this patch?

	I have successfully reproduced the problem and subsequently
validated this patch against 2.6.17.6.  I'm building netdev-2.6#upstream
right now, but I expect it will work as well (and will report back only
if it does not).

Acked-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
