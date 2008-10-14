From: Manfred Scherer <manfred.scherer.mhm@t-online.de>
Subject: Re: [Bugme-new] [Bug 11754] New: tlan network driver does not work
Date: Tue, 14 Oct 2008 13:16:03 +0200
Message-ID: <200810141316.04069.manfred.scherer.mhm@t-online.de>
References: <bug-11754-10286@http.bugzilla.kernel.org/> <20081014053236.69a71a2f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	mostrows@earthlink.net, Robert Fitzsimons <robfitz@273k.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout04.t-online.de ([194.25.134.18]:59296 "EHLO
	mailout04.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbYJNTkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 15:40:33 -0400
In-Reply-To: <20081014053236.69a71a2f.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

so far as I can see there are no changes in drivers/net/pppoe.c

pc1:/kernel/linux-2.6.27/drivers/net # diff -u /mnt_md10/kernelbaeckerei/linux-2.6.26/drivers/net/pppoe.c pppoe.c
pc1:/kernel/linux-2.6.27/drivers/net # echo $?
0
pc1:/kernel/linux-2.6.27/drivers/net #   

but a lot of changes in tlan.c

thus I think tlan.c is much more the causer for this problem.

Manfred Scherer 
____________________________________________________________________________________

Am Dienstag, 14. Oktober 2008 14:32 schrieb Andrew Morton:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> > On Mon, 13 Oct 2008 15:26:04 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=11754
> > 
> >            Summary: tlan network driver does not work
> >            Product: Drivers
> >            Version: 2.5
> >      KernelVersion: 2.6.27
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: jgarzik@pobox.com
> >         ReportedBy: Manfred.Scherer.Mhm@t-online.de
> > 
> > 
> > Latest working kernel version: 2.6.26
> > Earliest failing kernel version: 2.6.27
> 
> A 2.6.27 regression.
> 
> Not much has happened in tlan.c - a single fix from Robert.  This
> regression might be in pppoe?
> 
> 
> > Distribution: SuSE 9.2
> > Hardware Environment:
> > /var/log/boot.msg:
> > <6>ThunderLAN driver v1.15
> > <6>tlan 0000:00:0d.0: found PCI INT A -> IRQ 11
> > <6>tlan 0000:00:0d.0: sharing IRQ 11 with 0000:00:09.0
> > <6>TLAN: eth1 irq=11, io=c400, Compaq Netelligent 10/100 TX PCI UTP, Rev. 16
> > <6>TLAN: 1 device installed, PCI: 1  EISA: 0
> > ...
> > Setting up network interfaces:
> >     lo
> >     lo        IP address: 127.0.0.1/8
> > done    eth0      device: Realtek Semiconductor Co., Ltd. RTL-8029(AS)
> >     eth0      configuration: eth-id-52:54:00:db:15:ff
> >     eth0      IP address: 192.168.0.99/24
> > done    eth1      device: Compaq Computer Corporation Compaq Netelligent 10/100
> > TX PCI UTP TLAN 2.3 (rev 10)
> >     eth1      IP address: 192.168.1.22/24
> > done    dsl0
> >     dsl0      Startmode is 'manual'
> > 
> > 
> > Software Environment:
> > 
> > Problem Description:
> > 
> > PPPoe does not work
> > see /var/log/messages:
> > 
> > Oct 13 14:39:06 pc1 pppd[10123]: Plugin rp-pppoe.so loaded.
> > Oct 13 14:39:06 pc1 kernel: PPP generic driver version 2.4.2
> > Oct 13 14:39:06 pc1 pppd[10123]: RP-PPPoE plugin version 3.3 compiled against
> > pp
> > pd 2.4.2
> > Oct 13 14:39:06 pc1 pppd[10123]: Plugin passwordfd.so loaded.
> > Oct 13 14:39:06 pc1 kernel: NET: Registered protocol family 17
> > Oct 13 14:39:06 pc1 pppd[10123]: pppd 2.4.2 started by root, uid 0
> > Oct 13 14:39:41 pc1 pppd[10123]: Timeout waiting for PADO packets
> > Oct 13 14:39:41 pc1 pppd[10123]: Unable to complete PPPoE Discovery
> > Oct 13 14:39:41 pc1 pppd[10123]: Exit.
> > 
> > 
> > Steps to reproduce:
> > 
> > start dsl-connection to internet.
> > 
> 
> 
> 
