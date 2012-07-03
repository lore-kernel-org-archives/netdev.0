From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH net 1/7] qlge: Fixed packet transmit errors due to potential
 driver errors.
Date: Tue, 3 Jul 2012 08:58:35 +0530
Message-ID: <OFE8F5E8D9.DB59CE9B-ON65257A30.00128DF8-65257A30.00132AAC@in.ibm.com>
References: <20120702.171854.1585295090835924398.davem@davemloft.net>	<5E4F49720D0BAD499EE1F01232234BA877435B266A@AVEXMB1.qlogic.org>
	<20120702.183826.1521103644475572622.davem@davemloft.net> <20120702.184134.1131493483786674336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Dept_NX_Linux_NIC_Driver@qlogic.com, jitendra.kalsaria@qlogic.com,
	netdev@vger.kernel.org, ron.mercer@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:34610 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755317Ab2GCDaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 23:30:00 -0400
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Tue, 3 Jul 2012 08:59:56 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q633TNSm9044330
	for <netdev@vger.kernel.org>; Tue, 3 Jul 2012 08:59:23 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q638wv9b006068
	for <netdev@vger.kernel.org>; Tue, 3 Jul 2012 14:28:57 +0530
In-Reply-To: <20120702.184134.1131493483786674336.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> David Miller <davem@davemloft.net> 07/03/2012 07:11 AM
>
> >> As per your comments, TX ring full is not expected behavior? All I
> >> can think of increasing the TX queue to 1024 and clean-up in timer
> >> instead of interrupt?
> >
> > Your transmit function should never be invoked when the queue is
> > full, logic elsewhere in your driver should have stopped the queue
> > therefore preventing further invocations of your transmit function
> > until you wake the queue when space is liberated in the TX ring.
>
> BTW, did it even occur to you that there is a kernel log message here
> in this code path for a reason?
>
> That log message is there because this event is unexpected and a
> driver error.

Correctly coded drivers check for this condition:
"atomic_read(&tx_ring->tx_count) < 2" (without the
unlikely) once again at the end of the xmit and stop
the queue if required. Also, the message should be changed
to show that reaching here is an error.

thanks,
- KK
