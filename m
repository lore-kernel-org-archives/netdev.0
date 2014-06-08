From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs are
 probed into the Host
Date: Sun, 8 Jun 2014 12:16:53 +0300
Message-ID: <CAJZOPZJ2bvm31vB2skuWQ1tTYhX41cXwX0EzUyb_1KFN_zSeuA@mail.gmail.com>
References: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
	<20140602142947.GB28523@richard>
	<CAErSpo4GNxMMWyfcSnMKp65M6DAVwQkRCTuCbt+sWkOJTVt9Cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:47198 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbaFHJQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 05:16:54 -0400
Received: by mail-qg0-f47.google.com with SMTP id j107so7482416qga.20
        for <netdev@vger.kernel.org>; Sun, 08 Jun 2014 02:16:53 -0700 (PDT)
In-Reply-To: <CAErSpo4GNxMMWyfcSnMKp65M6DAVwQkRCTuCbt+sWkOJTVt9Cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 2, 2014 at 7:10 PM, Bjorn Helgaas <bhelgaas@google.com> wrote:
[...]
>   From the PCI core's perspective, after .probe() returns successfully,
>   we can call any driver entry point and pass the pci_dev to it, and
>   expect it to work.  Doing mlx4_remove_one() in mlx4_pci_err_detected()

note that __mlx4_remove_one() is what called from mlx4_pci_err_detected()
and the former is built in a way which allows it to be called twice.

In that respect, I agree to the fix provided by Wei Yang over this thread, which
essentially makes .shutdown to behave in a similar way and call
__mlx4_remove_one()
and will submit it for inclusion.

>   sort of breaks that assumption because you clear out pci_drvdata().
>   Right now, the only other entry point mlx4 really implements is
>   mlx4_remove_one(), and it has a hack that tests whether pci_drvdata()
>   is NULL.  But that's ... a hack, and you'll have to do the same
>   if/when you implement suspend/resume/sriov_configure/etc.
