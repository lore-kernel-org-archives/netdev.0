From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 3.14-stable] net/mlx4_core: Preserve pci_dev_data after __mlx4_remove_one()
Date: Sun, 1 Jun 2014 13:52:54 +0300
Message-ID: <CAJZOPZ+5wkQmabjUhK138akLCVZUY8BQkwhGuX-ssV+UFVn4Ww@mail.gmail.com>
References: <1401607475-8367-1-git-send-email-weiyang@linux.vnet.ibm.com>
	<20140601073853.GA8635@richard>
	<538AF2CB.20603@mellanox.com>
	<538AF412.9080406@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:60894 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383AbaFAKwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 06:52:55 -0400
Received: by mail-qa0-f46.google.com with SMTP id w8so1163940qac.19
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 03:52:54 -0700 (PDT)
In-Reply-To: <538AF412.9080406@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 1, 2014 at 12:36 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> On 01/06/2014 12:30, Or Gerlitz wrote:

>> Wait, I recently noticed that on 3.15-rcX if the host is rebooted when the
>> mlx4_core driver is loaded in SRIOV mode, we crash like that, looking on
>> this now, I think there's chance we can relate it to your upstream change
>> befdf89 "net/mlx4_core: Preserve pci_dev_data after __mlx4_remove_one()"


> this seems to fix the crash, will further evaluate and submit patch later today

We ended up with a slightly different fix, let's see it hits well 3.15 and then
you can resume your -stable efforts.

Or.

> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2629,7 +2629,7 @@ static void __mlx4_remove_one(struct pci_dev *pdev)
>         int               pci_dev_data;
>         int p;
>
> -       if (priv->removed)
> +       if (!priv || priv->removed)
>                 return;
>
>         pci_dev_data = priv->pci_dev_data;
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
