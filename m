From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Mon, 16 Jun 2008 23:29:02 +0300
Message-ID: <20080616202743.M97685@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <4856C9ED.3070505@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org,
	e1000-list <e1000-devel@lists.sourceforge.net>
To: Auke Kok <auke@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:37310 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbYFPU3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 16:29:21 -0400
In-Reply-To: <4856C9ED.3070505@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did in previous message.
Here is more information about hardware.

Base Board Information
        Manufacturer: Intel Corporation
        Product Name: DQ965GF
        Version: AAD41676-402
        Serial Number: BQGF712003M6



MegaRouter-KARAM ~ # lspci -t
-[0000:00]-+-00.0
           +-01.0-[0000:01]--
           +-02.0
           +-03.0
           +-03.2
           +-03.3
           +-19.0
           +-1a.0
           +-1a.1
           +-1a.7
           +-1b.0
           +-1c.0-[0000:02]--
           +-1c.1-[0000:03]----00.0
           +-1c.2-[0000:04]--
           +-1c.3-[0000:05]--
           +-1c.4-[0000:06]--
           +-1d.0
           +-1d.1
           +-1d.2
           +-1d.7
           +-1e.0-[0000:07]----00.0
           +-1f.0
           +-1f.2
           \-1f.3
MegaRouter-KARAM ~ # lspci -t -v
-[0000:00]-+-00.0  Intel Corporation 82Q963/Q965 Memory Controller Hub
           +-01.0-[0000:01]--
           +-02.0  Intel Corporation 82Q963/Q965 Integrated Graphics Controller
           +-03.0  Intel Corporation 82Q963/Q965 HECI Controller
           +-03.2  Intel Corporation 82Q963/Q965 PT IDER Controller
           +-03.3  Intel Corporation 82Q963/Q965 KT Controller
           +-19.0  Intel Corporation 82566DM Gigabit Network Connection
           +-1a.0  Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #4
           +-1a.1  Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #5
           +-1a.7  Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #2
           +-1b.0  Intel Corporation 82801H (ICH8 Family) HD Audio Controller
           +-1c.0-[0000:02]--
           +-1c.1-[0000:03]----00.0  Marvell Technology Group Ltd. 88SE6101
single-port PATA133 interface
           +-1c.2-[0000:04]--
           +-1c.3-[0000:05]--
           +-1c.4-[0000:06]--
           +-1d.0  Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #1
           +-1d.1  Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #2
           +-1d.2  Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #3
           +-1d.7  Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #1
           +-1e.0-[0000:07]----00.0  Linksys Gigabit Network Adapter
           +-1f.0  Intel Corporation 82801HO (ICH8DO) LPC Interface Controller
           +-1f.2  Intel Corporation 82801HR/HO/HH (ICH8R/DO/DH) 6 port SATA
AHCI Controller
           \-1f.3  Intel Corporation 82801H (ICH8 Family) SMBus Controller





On Mon, 16 Jun 2008 13:15:41 -0700, Auke Kok wrote
> Denys Fedoryshchenko wrote:
> > Hi again
> > 
> > I moved from PCI Realtek 8169 to onboard PCI-Express e1000e, and situation
> > become worse. Strange? Yes.
> > 
> > Here is info
> > Load and error rate: 
> > 
> > MegaRouter-KARAM /sys # ifconfig eth1;sleep 10;ifconfig eth1
> > eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
> >           inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >           RX packets:91991642 errors:0 dropped:1803444 overruns:0 frame:0
> >           TX packets:91914611 errors:0 dropped:0 overruns:0 carrier:0
> >           collisions:0 txqueuelen:1000
> >           RX bytes:316112765 (301.4 MiB)  TX bytes:138303107 (131.8 MiB)
> >           Memory:90300000-90320000
> > 
> > eth1      Link encap:Ethernet  HWaddr 00:19:D1:71:5F:33
> >           inet addr:192.168.20.10  Bcast:0.0.0.0  Mask:255.255.255.0
> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >           RX packets:92812514 errors:0 dropped:1815490 overruns:0 frame:0
> >           TX packets:92734865 errors:0 dropped:0 overruns:0 carrier:0
> >           collisions:0 txqueuelen:1000
> >           RX bytes:739941322 (705.6 MiB)  TX bytes:560547138 (534.5 MiB)
> >           Memory:90300000-90320000
> > 
> > System load (there is no NAT, no shapers, just routing, around 600-700
routes):
> > MegaRouter-KARAM /sys # mpstat 1
> > Linux 2.6.26-rc6-git2-build-0029 (MegaRouter-KARAM)     06/16/08
> > 
> > 22:36:36     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal  
> > %idle    intr/s
> > 22:36:37     all    0.00    0.00    0.00    0.00    0.00    1.49    0.00  
> > 98.51  19764.00
> > 22:36:38     all    0.00    0.00    0.50    0.00    0.00    0.50    0.00  
> > 99.01  19888.00
> > 22:36:39     all    0.00    0.00    0.00    0.00    0.00    0.50    0.00  
> > 99.50  19642.00
> > 22:36:40     all    0.00    0.00    0.00    0.00    1.01    9.05    0.00  
> > 89.95  19543.00
> > 
> > (system almost idle)
> 
> but has 20000 interrupts per second! that's hardly idle by any 
> account :)
> 
> what options did use to load e1000e? can you show the relevant dmesg 
> parts? post contents of /proc/interrupts?
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

