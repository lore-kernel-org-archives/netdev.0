From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Detecting backup slaves of bonding interface in network driver
Date: Fri, 12 Dec 2008 08:37:45 -0800
Message-ID: <3481.1229099865@death.nxdomain.ibm.com>
References: <494108D7.3040304@gslab.com> <25821.1229013359@death.nxdomain.ibm.com> <4942663A.3080801@gslab.com>
Cc: netdev@vger.kernel.org
To: Poornima Kamath <poornimak@gslab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:51391 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759333AbYLLQht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2008 11:37:49 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBCGb5ip031246
	for <netdev@vger.kernel.org>; Fri, 12 Dec 2008 11:37:05 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBCGbmCh165204
	for <netdev@vger.kernel.org>; Fri, 12 Dec 2008 11:37:48 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBCGbmue010945
	for <netdev@vger.kernel.org>; Fri, 12 Dec 2008 11:37:48 -0500
In-reply-to: <4942663A.3080801@gslab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Poornima Kamath <poornimak@gslab.com> wrote:

>The driver creates virtual interfaces that talk to ethernet interfaces over
>infiniband,  using an infiniband to ethernet gateway device.
>The gateway device sends data to all interfaces having same mac address.  For
>this the driver needs to explicitly tell the gateway device not to send data to
>the backup slaves.
>Therefore the driver needs to  know which slaves are backup slaves.
>The failover mac option  works well,  but it is present for kernels greater
>than 2.6.24.  So this option is not available for distros like RHEL5, SLES10
>etc

	I believe that RHEL5 and SLES10 contain an "ib-bonding" package
which includes a backport of the current (or at least a more current)
bonding driver specifically for use over Infiniband.  I think it's also
got a couple of other patches to bonding that aren't in the mainline.
In any event, it has the fail_over_mac functionality.

	Have you looked at ib-bonding?

>So in order to support these distros I need some way of identifying the backup
>slaves.
>Is it ok to check the IFF_SLAVE_INACTIVE flags for these distros?

	It will do what you want (identify backup slaves), and is not
guaranteed to be available in the future.  I doubt that the flag would
ever go away on RHEL5 or SLES10, but, again, no guarantee.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
