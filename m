From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 0/7] [S390]: Introduction of AF_IUCV sockets support
Date: Fri, 2 Feb 2007 13:05:28 +0100
Message-ID: <20070202120528.GA10392@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:36386 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422947AbXBBMGp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 07:06:45 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l12C6iAE019254
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:44 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l12C6iV4286330
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:44 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l12C6iDo018116
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:44 -0500
Received: from goulee.de.ibm.com (dyn-9-152-216-77.boeblingen.de.ibm.com [9.152.216.77])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id l12C6hC1018058
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 07:06:44 -0500
Received: from goulee.de.ibm.com (localhost.localdomain [127.0.0.1])
	by goulee.de.ibm.com (8.13.1/8.13.1) with ESMTP id l12C5TMI014211
	for <netdev@vger.kernel.org>; Fri, 2 Feb 2007 13:05:29 +0100
Received: (from pavlic@localhost)
	by goulee.de.ibm.com (8.13.1/8.13.1/Submit) id l12C5TYb014208
	for netdev@vger.kernel.org; Fri, 2 Feb 2007 13:05:29 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
The Inter-User Communication Vehicle (IUCV) is a z/VM communication facility 
that enables a program running in one virtual machine to communicate with 
another virtual machine, or with a control program, or even with itself. 
The communication takes place over a predefined linkage called a path.
AF_IUCV provides a complete socket interface for socket communication 
from Linux to Linux (running on z/VM) or Linux on VM to CMS.
The AF_IUCV Protocol Support will use IUCV to provide AF_IUCV 
protocol support for communication with z/VM back-end services.
It also can connect socket applications operating in Linux kernels 
running on different VM user IDs, or to connect a Linux 
application to another socket application running in a VM guest.
AF_IUCV is using a different addressing scheme and therefore there is no
chance to use existing drivers like netiucv for such functionality.

The patch set consists of following patches:

[1/7] [S390]: Rewrite of the IUCV base code, part 1
[2/7] [S390]: Rewrite of the IUCV base code, part 2
[3/7] [S390]: Adapt monreader driver to new IUCV API
[4/7] [S390]: Adapt vmlogrdr driver to new IUCV API
[5/7] [S390]: Adapt netiucv driver to new IUCV API
[6/7] [S390]: Adapt special message interface to new IUCV API
[7/7] [S390]: Add AF_IUCV socket support

Basically it will remove the old IUCV base code from drivers/s390/net,
adds the new rewritten one to net/iucv.
Then all iucv based device drivers like monreader, 
vmlogrdr, netiucv and special message interface 
will be adapted to the new IUCV API.
The last patch then adds the AF_IUCV socket support residing
in net/iucv either.

I am asking for integration now and of course 
code review comments and suggestions are very appreciated .

Thank you very much

Frank
