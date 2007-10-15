From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Mon, 15 Oct 2007 14:53:01 +0200
Message-ID: <20071015125301.GC3015@ff.dom.local>
References: <Pine.LNX.4.64N.0709171750220.17606@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W\. Rozycki" <macro@linux-mips.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763383AbXJOMuW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64N.0709171750220.17606@blysk.ds.pg.gda.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19-09-2007 16:38, Maciej W. Rozycki wrote:
...
> @@ -661,13 +664,22 @@ int phy_stop_interrupts(struct phy_devic
>  	if (err)
>  		phy_error(phydev);
>  
> +	free_irq(phydev->irq, phydev);
> +
>  	/*
> -	 * Finish any pending work; we might have been scheduled to be called
> -	 * from keventd ourselves, but cancel_work_sync() handles that.
> +	 * Cannot call flush_scheduled_work() here as desired because
> +	 * of rtnl_lock(), but we do not really care about what would
> +	 * be done, except from enable_irq(), so cancel any work
> +	 * possibly pending and take care of the matter below.
>  	 */
>  	cancel_work_sync(&phydev->phy_queue);

Hi,

Could you explain why cancel_work_sync() is better here than
flush_scheduled_work() wrt. rtnl_lock()?

Regards,
Jarek P.
