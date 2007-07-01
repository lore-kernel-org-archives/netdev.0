From: Michael Buesch <mb@bu3sch.de>
Subject: Re: RESEND [PATCH 3/3] NetXen: Graceful teardown of interface and hardware upon module unload
Date: Sun, 1 Jul 2007 22:23:04 +0200
Message-ID: <200707012223.04514.mb@bu3sch.de>
References: <20070701185558.881537150@netxen.com> <20070701190017.829260145@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob@netxen.com,
	Milan Bag <mbag@netxen.com>, Wen Xiong <wenxiong@us.ibm.com>
To: dhananjay.phadke@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:41499
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759585AbXGAUXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2007 16:23:49 -0400
In-Reply-To: <20070701190017.829260145@netxen.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 01 July 2007 20:56:01 dhananjay.phadke@gmail.com wrote:
> These changes allow driver close routine to be called during module unload,
> to clean-up buffers and other software resources, flush queues etc. Also,
> hardware is reset to pristine state. 
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> Signed-off-by: Milan Bag <mbag@netxen.com>
> Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>
> 


> +			msleep(1);
> +			if (netxen_load_firmware(adapter))
> +				return;
> +			netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
> +		}
> +
> +		/* clear the register for future unloads/loads */
> +		writel(0, NETXEN_CRB_NORMALIZE(adapter, NETXEN_CAM_RAM(0x1fc)));
> +		printk(KERN_INFO "State: 0x%0x\n",
> +			readl(NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE)));
> +
> +		dma_watchdog_shutdown_request(adapter);
> +		mdelay(100);
> +		i = 100;
> +		while ((dma_watchdog_shutdown_poll_result(adapter) != 1) && i) {
> +			printk(KERN_INFO "dma_watchdog_shutdown_poll still in progress\n");
> +			mdelay(100);
> +			i--;
> +		}

msleep, please.

-- 
Greetings Michael.
