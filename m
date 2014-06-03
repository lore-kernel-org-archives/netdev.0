From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs
 are probed into the Host
Date: Mon, 02 Jun 2014 17:58:16 -0700 (PDT)
Message-ID: <20140602.175816.1677581007124366598.davem@davemloft.net>
References: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
	<20140602142947.GB28523@richard>
	<CAErSpo4GNxMMWyfcSnMKp65M6DAVwQkRCTuCbt+sWkOJTVt9Cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyang@linux.vnet.ibm.com, ogerlitz@mellanox.com,
	netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il
To: bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212AbaFCA6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 20:58:18 -0400
In-Reply-To: <CAErSpo4GNxMMWyfcSnMKp65M6DAVwQkRCTuCbt+sWkOJTVt9Cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjorn Helgaas <bhelgaas@google.com>
Date: Mon, 2 Jun 2014 10:10:01 -0600

> Writing a driver is not an empirical process of trying things to see
> what works.  You need to actively design a consistent structure so you
> know why and when things are safe.  I object to gratuitous "dev ==
> NULL" checks because often they are just a way of patching up a driver
> design that isn't well thought-out.
> 
> As I wrote before:
> 
>   From the PCI core's perspective, after .probe() returns successfully,
>   we can call any driver entry point and pass the pci_dev to it, and
>   expect it to work.  Doing mlx4_remove_one() in mlx4_pci_err_detected()
>   sort of breaks that assumption because you clear out pci_drvdata().
>   Right now, the only other entry point mlx4 really implements is
>   mlx4_remove_one(), and it has a hack that tests whether pci_drvdata()
>   is NULL.  But that's ... a hack, and you'll have to do the same
>   if/when you implement suspend/resume/sriov_configure/etc.

Agreed.
