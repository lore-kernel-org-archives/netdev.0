From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Fri, 30 Nov 2012 18:00:07 +0100
Message-ID: <20121130170007.GA25818@shrek.podlesie.net>
References: <201211300138.qAU1c8sE003388@thirdoffive.cmf.nrl.navy.mil>
 <1354240620.21562.256.camel@shinybook.infradead.org>
 <1354263922.21562.270.camel@shinybook.infradead.org>
 <20121130095354.GA15126@shrek.podlesie.net>
 <1354277415.21562.284.camel@shinybook.infradead.org>
 <1354292626.21562.298.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>,
	David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354292626.21562.298.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 30, 2012 at 04:23:46PM +0000, David Woodhouse wrote:
> 
> +static void br2684_release_cb(struct atm_vcc *atmvcc)
> +{
> +	struct br2684_vcc *brvcc = BR2684_VCC(atmvcc);
> +
> +	/*
> +	 * A race with br2684_xmit_vcc() might cause a spurious wakeup just
> +	 * after that function *stops* the queue, and qspace might actually
> +	 * go negative before the queue stops again. We cope with that.
> +	 */

We cannot race with br2684_xmit_vcc() because both br2684_xmit_vcc()
and br2684_release_cb() are called with locked sk->sk_lock.slock.

> +	if (atomic_read(&brvcc->qspace) > 0)
> +		netif_wake_queue(brvcc->device);
> +
> +	if (brvcc->old_release_cb)
> +		brvcc->old_release_cb(atmvcc);
> +}

Except that comment, the patch looks good:

Acked-by: Krzysztof Mazur <krzysiek@podlesie.net>

Krzysiek
