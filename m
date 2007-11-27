From: "Love, Robert W" <robert.w.love@intel.com>
Subject: [ANNOUNCE] Open-FCoE - Fibre Channel over Ethernet Project
Date: Tue, 27 Nov 2007 10:49:11 -0800
Message-ID: <10A7D0016239E24092DEF05CCC582E43028A636B@fmsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <devel@open-fcoe.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>,
	"Rob Love" <robert.w.love@linux.intel.com>,
	"Love, Robert W" <robert.w.love@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	"Zou, Yi" <yi.zou@intel.com>, "Dev, Vasu" <vasu.dev@intel.com>,
	<james.bottomley@hansenpartnership.com>, <davem@davemloft.net>,
	<jeff@garzik.org>, "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Van De Ven, Arjan" <arjan.van.de.ven@intel.com>,
	"Mike Christie" <michaelc@cs.wisc.edu>
To: <linux-scsi@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:45766 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755972AbXK0Su6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 13:50:58 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Linux Community,

    I'd like to introduce a new Open Source project named Open-FCoE.
FCoE is the acronym for Fibre Channel over Ethernet, which is the
encapsulation of Fibre Channel frames within Ethernet packets. FCoE will
allow systems with an Ethernet adapter and a Fibre Channel Forwarder to
login to a Fibre Channel fabric (the FCF is a "gateway" that bridges the
LAN and the SAN). That fabric login was previously reserved exclusively
for Fibre Channel HBAs. This technology reduces complexity in the data
center by aiding network convergence. It is targeted for 10Gps Ethernet
NICs but will work on any Ethernet NIC supporting pause frames. Our code
base provides a Fibre Channel protocol processing module as well as an
Ethernet based transport module. The Open-FC module acts as a LLD for
SCSI and the Open-FCoE transport uses net_device to send and receive
packets.

    We've set up a "web home" for this project at www.Open-FCoE.org. Its
purpose is to support development and users; it's very light on content
right now. 

    We have a lot of code and it will take time for us to harden and
improve upon it. We're still early in development but are making this
code available as soon as possible so that our project's development can
truly be open.


This is our code's organization as it is today.

1) git://open-fcoe.org/openfc/open-fcoe-upstream.git
      
      This repository is based on the SCSI 2.6.24 bug fix tree. Two
patches are applied to add our code and resolve any compatibility
problems between our code and 2.6.24.

2) git://open-fcoe.org/openfc/open-fcoe.git

       This repository contains our user space tools. It also contains
an out-of-kernel Makefile that allows a user to build the kernel modules
within this layout. Pulling our kernel code from open-fcoe-upstream into
this code base and then tarring it up provides an easily distributable
package.

3) git://open-fcoe.org/openfc/open-fcoe-misc.git

       This repository contains our SW target code. The SW target allows
someone to connect two systems back-to-back and run FCoE traffic from
one to another. Currently our target uses SCST which is not upstream.
This is causing us a problem because the target shares code with the
initiator.  Since the initiator is building with 2.6.24 and SCST isn't
we're in a bind.  A priority of ours will be to get the target back to a
better shape as it's our primary development tool.


We also have a lot of things to fix. Here are our initial concerns,

1) Kernel/Userspace interaction needs direction. Currently we're using
ioctls, which are no longer desirable. We're planning to change the
implementation to netlink. Also, some non-data path code will probably
need to move to user space. Open-iSCSI has spent a lot of time on its
kernel to user interaction; we will likely borrow from that model as
much as we can.

2) SW Target and its integration with the kernel.

3) Reduction of code, removal of unnecessary abstraction.

4) Non-GPL code. We're currently using a BSD queue.h and some CRC code
from BSD as well. We need to convert this code to use kernel code.

5) Documentation. Our basic documentation needs some help so people can
use the initiator and target easily.


We have a mailing list established on our website, but believe that the
community will want us to discuss this technology on the SCSI mailing
list. That is where we plan to start discussing this code.

We're looking forward to building a strong community around this
technology and code base. We're eager to start coding and improving our
code with any other community contributors!


Robert Love
Open-FCoE.org
