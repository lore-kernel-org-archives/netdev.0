From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net v3] r8169:fix "rtl_counters_cond == 1 (loop: 1000,
 delay: 10)" log spam.
Date: Tue, 23 Feb 2016 23:44:00 +0100
Message-ID: <20160223224400.GA22343@electric-eye.fr.zoreil.com>
References: <1456216103-8113-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chunhao Lin <hau@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456216103-8113-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chunhao Lin <hau@realtek.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 537974c..404be51 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -7853,6 +7859,11 @@ static int rtl8169_runtime_suspend(struct device *device)
>  
>  	rtl8169_net_suspend(dev);
>  
> +	/* Update counters before going runtime suspend */
> +	if (netif_running(dev))

This test is useless (always true):

- rtl_open
  [...]
  pm_runtime_get_sync(&pdev->dev);
  [...]
  tp->TxDescArray = blah
  [...]

- rtl8169_close
  [...]
  pm_runtime_get_sync(&pdev->dev);
  [...]
  tp->TxDescArray = NULL;

- rtl8169_runtime_suspend
  [...]
  if (!tp->TxDescArray)
  	  return 0;

(the implicit smp barriers are mildly obvious, ok)

-- 
Ueimor
