From: =?iso-8859-1?Q?Kurt_Sch=E4big?= <kurt@crelm.de>
Subject: ADMtek AN983B (DEC Tulip compatible) nic problem (fix included)
Date: Fri, 26 Apr 2002 19:05:48 +0200 (MEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <aac1dt$rtc$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

and sorry if I am wrong here - I did not find a better address to mail
this to.

The Problem:
The driver module for the DEC Tulip compatible nic does not recognize the
ADMtek AN938B network controller, although it should.
Neither does the v2.4 kernel module, nor does v2.5. The vendor says
version 2.0.x kernels would have worked, but I did not test it.

The Diagnosis:
There is a list of vendor and device ids "tulip_pci_tbl []" in
linux/drivers/net/tulip/tulip_core.c
The module selects correct device handling data based on the pci vendor
and device ids in this list, and the nic's values are missing.

The AN983B nic identifies as vendor 0x1317, device 0x9511. The list indeed
contains vendor 0x1317, but without this device id, and also contains the
device id, but not related to this vendor.

The Fix:
I have just added the line
--->
   { 0x1317, 0x9511, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
<--
in the file tulip_core.c after line 207, and the nic works.
(The kernel version was 2.4.17)

The Tests:
Once it loaded correctly, we have heavily tested the Tulip driver with
this controller. First I had a test drive with lots of traffic overnight
running without problems, now we have four or five servers running with
this nic for a week, two of them with quite some internet traffic.
Therefore I suppose there is no other trick or patch necessary to
have this nic working correctly, just the vendor/device ids are missing.

Unfortunately we have only one version of this controller, it is located
on the MSI MS-6378 rev. 3.1 mother boards. It seems to be an universal nic
although, see http://www.admtek.com.tw/ for details.
So we have not tested other instances of this hardware, only this one.

Regards
Kurt

