From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Bonding and Neighbour Discovery on IPv6-only devices
Date: Wed, 24 Sep 2008 13:29:48 -0700
Message-ID: <7958.1222288188@death.nxdomain.ibm.com>
References: <200809151335.16817.asid@hp.com> <20080915180015.GB1078@havoc.gtf.org> <200809151416.49447.alexandre.sidorenko@hp.com> <48DA71A8.5050900@hp.com>
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:33512 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202AbYIXUaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 16:30:23 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8OKWqgY021693
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 16:32:52 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8OKU6Zf288206
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 16:30:06 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8OKU6kq001099
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 16:30:06 -0400
In-reply-to: <48DA71A8.5050900@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
[...]
>It doesn't.  What appears to happen in the active-backup case the MLD reports
>are not generated on all of the slave devices, just the active one.  Thus the
>switch knows only about the active device.

	This behavior is by design.  Previously, it worked the other way
(every slave did IPv6 addrconf stuff, etc), but that confused the
switches because they'd snoop the addrconf traffic whenever a backup
slave came up, and update the switch forwarding table.

>When you force the failover, no reports happen because the device believes that
>the MLD group was already reported.  Thus there needs to be some trigger after
>the failover to tell the switch that the mac address and multicast group have
>moved to a different port.

	Yes, there needs to be an ipv6 equivalent of the gratuitous ARP
and IGMP rejoin that's done for ipv4.  I haven't figured out how to
accomplish that yet; suggestions are welcome.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
