From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs are
 probed into the Host
Date: Tue, 3 Jun 2014 11:15:43 +0300
Message-ID: <CAJZOPZK94-hZfBtpjFMEd5m1STRxbs-wTYsKB5SoC=zES5XfPg@mail.gmail.com>
References: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
	<20140602142947.GB28523@richard>
	<CAErSpo4GNxMMWyfcSnMKp65M6DAVwQkRCTuCbt+sWkOJTVt9Cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Bjorn Helgaas <bhelgaas@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f47.google.com ([209.85.216.47]:37458 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbaFCIPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 04:15:44 -0400
Received: by mail-qa0-f47.google.com with SMTP id s7so4304480qap.20
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 01:15:43 -0700 (PDT)
In-Reply-To: <CAErSpo4GNxMMWyfcSnMKp65M6DAVwQkRCTuCbt+sWkOJTVt9Cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 2, 2014 at 7:10 PM, Bjorn Helgaas <bhelgaas@google.com> wrote:
> Writing a driver is not an empirical process of trying things to see
> what works.  You need to actively design a consistent structure so you
> know why and when things are safe.  I object to gratuitous "dev ==
> NULL" checks because often they are just a way of patching up a driver
> design that isn't well thought-out.

Bjorn, 1st and most -- Agreed.

Next, to be precise, the use case of rebooting the host while the
driver was loaded in SRIOV mode and NO VFs probed to VMs worked before
commit befdf89 and is now broken.

Reading further your response, I understand that the code was probably
using a sort of hackish branching to make that to happen, and you
suggest we re-write that section properly so it can serve well when
(hopefully soon) implemenet
sriov_configure and possibly also suspend/resume, point taken.

Dave, as for this patch, again, the regression of inability to reboot
the host node
while the driver is loaded exists in the latest upstream code as of
befdf89 / 3.15-rc1

Now, taking into account that 3.15 is after rc8 and the IL devel team
has a holiday this week, I don't see us coming in time with a more
deeper fix for 3.15, so maybe you can eventaully go and merge this one
liner for 3.15?

Or.


> As I wrote before:
>   From the PCI core's perspective, after .probe() returns successfully,
>   we can call any driver entry point and pass the pci_dev to it, and
>   expect it to work.  Doing mlx4_remove_one() in mlx4_pci_err_detected()
>   sort of breaks that assumption because you clear out pci_drvdata().
>   Right now, the only other entry point mlx4 really implements is
>   mlx4_remove_one(), and it has a hack that tests whether pci_drvdata()
>   is NULL.  But that's ... a hack, and you'll have to do the same
>   if/when you implement suspend/resume/sriov_configure/etc.
