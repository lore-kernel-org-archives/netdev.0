From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [RESEND PATCH 0/7] [S390]: Introduction of AF_IUCV sockets support
Date: Mon, 5 Feb 2007 15:00:50 +0100
Message-ID: <20070205140050.GA19137@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-s390@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:54451 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932585AbXBEOBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 09:01:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
seems that Patch 1/7 is lost and did not make its way to the mailing list :-(
That's the reason why I resend the whole patch set again.
Here we go ...

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
