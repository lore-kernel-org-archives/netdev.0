From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: active-backup/bonding with drivers not supporting set_mac_address()
Date: Mon, 10 Jul 2006 22:29:57 -0700
Message-ID: <200607110529.k6B5Tvhg006390@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0607101618390.26558@zuben> <200607101829.k6AITEp0026893@death.nxdomain.ibm.com> <20060710.114530.125253070.davem@davemloft.net>
Cc: ogerlitz@voltaire.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:24528 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S965067AbWGKFaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 01:30:01 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6B5U0B0024581
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 01:30:00 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6B5U06D289682
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 01:30:00 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6B5TxbN021058
	for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 01:29:59 -0400
To: David Miller <davem@davemloft.net>
In-reply-to: <20060710.114530.125253070.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

>Look at a driver such as 3c509.c, for example.
[...]
>If the driver isn't setting up an explicit ->set_mac_address handler,
>it isn't going to be programming the RX MAC of the chip and therefore
>not recognize packets to that new MAC as destined for it.

	If I'm not mistaken, it looks like 3c509.c sets the MAC on the
chip from dev->dev_addr in el3_up():

	/* Set the station address in window 2 each time opened. */
	EL3WINDOW(2);

	for (i = 0; i < 6; i++)
		outb(dev->dev_addr[i], ioaddr + i);

	I don't have the spec for 3c509 handy, but 3c59x.c does the same
thing in vortex_up(), and its spec says the first 6 bytes of register
window 2 are the "StationAddress".

	So, I'm still wondering what drivers really never let you change
the MAC address.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
