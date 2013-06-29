From: Johannes Stezenbach <js@sig21.net>
Subject: Re: [PATCH 8/8] alx: remove WoL support
Date: Sat, 29 Jun 2013 21:12:48 +0200
Message-ID: <20130629191248.GA10570@sig21.net>
References: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
 <1372526600-15934-9-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:41986 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752384Ab3F2TNw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jun 2013 15:13:52 -0400
Content-Disposition: inline
In-Reply-To: <1372526600-15934-9-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 29, 2013 at 07:23:20PM +0200, Johannes Berg wrote:
> Unfortunately, WoL is broken and the system will immediately
> resume after suspending, and I can't seem to figure out why.
> Remove WoL support until the issue can be found.
...
> -#ifdef CONFIG_PM_SLEEP
> -static SIMPLE_DEV_PM_OPS(alx_pm_ops, alx_suspend, alx_resume);
> -#define ALX_PM_OPS      (&alx_pm_ops)
> -#else
> -#define ALX_PM_OPS      NULL
> -#endif
> -
>  static DEFINE_PCI_DEVICE_TABLE(alx_pci_tbl) = {
>  	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8161),
>  	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
> @@ -1614,9 +1472,7 @@ static struct pci_driver alx_driver = {
>  	.id_table    = alx_pci_tbl,
>  	.probe       = alx_probe,
>  	.remove      = alx_remove,
> -	.shutdown    = alx_shutdown,
>  	.err_handler = &alx_err_handlers,
> -	.driver.pm   = ALX_PM_OPS,
>  };

Not sure but doesn't that mean the driver breaks after suspend?
I think you removed too much, not just WOL support but all pm handling.


Johannes
