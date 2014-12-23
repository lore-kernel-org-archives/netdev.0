From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH v3 3/3] igb: Fix a memory leak in igb_probe
Date: Tue, 23 Dec 2014 12:59:31 +0530
Message-ID: <CAEUmHyaX5RUMZOE5G6nzXM8O-q0whCEv1ux7ceJY04uU+mw41g@mail.gmail.com>
References: <1419319024-30455-1-git-send-email-baijiaju1990@163.com>
	<1419319024-30455-3-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"<linux.nics@intel.com>" <linux.nics@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:46568 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbaLWH3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 02:29:33 -0500
Received: by mail-la0-f47.google.com with SMTP id hz20so4953139lab.6
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 23:29:32 -0800 (PST)
In-Reply-To: <1419319024-30455-3-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 23, 2014 at 12:47 PM, Jia-Ju Bai <baijiaju1990@163.com> wrote:
> For linux-3.18.0
> The driver calls kcalloc to allocate memory for adapter->shadow_vfta
> in igb_sw_init, but kfree is not called in error handling of igb_probe.
> So when register_netdev or igb_init_i2c is failed, a memory leak occurs.
> This patch fixes this problem, and it has been tested in runtime.
>
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index 487cd9c..a0be1e5 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -2659,6 +2659,7 @@ err_eeprom:
>         if (hw->flash_address)
>                 iounmap(hw->flash_address);
>  err_sw_init:
> +       kfree(adapter->shadow_vfta);
Why dont you use devm_kcalloc()..? So no need to worry about freeing it.
>         igb_clear_interrupt_scheme(adapter);
>         pci_iounmap(pdev, hw->hw_addr);
>  err_ioremap:
> --
> 1.7.9.5
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Thanks and Regards,
Varka Bhadram.
