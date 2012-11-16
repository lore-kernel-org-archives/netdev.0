From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v5 1/2] PCI-Express Non-Transparent Bridge Support
Date: Thu, 15 Nov 2012 16:29:59 -0800
Message-ID: <20121116002959.GB20876@kroah.com>
References: <1352160669-4330-1-git-send-email-jon.mason@intel.com>
 <1352160669-4330-2-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1352160669-4330-2-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 05, 2012 at 05:11:08PM -0700, Jon Mason wrote:
> +static int __init ntb_init_module(void)
> +{
> +	pr_info("%s: %s, version %s\n", KBUILD_MODNAME, NTB_NAME, NTB_VER);

No need to be noisy.

> +
> +	return pci_register_driver(&ntb_pci_driver);
> +}
> +module_init(ntb_init_module);
> +
> +static void __exit ntb_exit_module(void)
> +{
> +	pci_unregister_driver(&ntb_pci_driver);
> +
> +	pr_info("%s: Driver removed\n", KBUILD_MODNAME);

Same here, don't print out needless things.

> +}
> +module_exit(ntb_exit_module);

This all can be wrapped up using the pci_module() macro instead.

thanks,

greg k-h
