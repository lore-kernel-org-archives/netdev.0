From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 4/4] net: macb: Add hardware PTP support
Date: Wed, 7 Jun 2017 15:28:17 +0200
Message-ID: <20170607132817.GA28329@localhost.localdomain>
References: <1496413439-12900-1-git-send-email-rafalo@cadence.com>
 <1496413690-22826-1-git-send-email-rafalo@cadence.com>
 <20170606183358.GA25220@localhost.localdomain>
 <BN3PR07MB2516A47C2CFEB58BCFFB2C46C9C80@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org" <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org" <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
        "andrei.pistirica-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org" <andrei.pistirica-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>
To: Rafal Ozieblo <rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BN3PR07MB2516A47C2CFEB58BCFFB2C46C9C80-EldUQEzkDQfxGZiqM5fOI+FPX92sqiQdvxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 07, 2017 at 11:13:36AM +0000, Rafal Ozieblo wrote:
> Please look at following call-stack:
> 
> 1. macb_interrupt()   // spin_lock(&bp->lock) is taken
> 2. macb_tx_interrupt()
> 3. macb_handle_txtstamp()
> 4. skb_tstamp_tx()
> 5. __skb_tstamp_tx()
> 6. skb_may_tx_timestamp()
> 7. read_lock_bh() // second lock is taken

Well, you can always drop the lock, or postpone the call to
skb_tstamp_tx() until after the spin lock is released...

> I know that those are different locks and different types. But this could lead 
> to deadlocks. This is the reason of warning I could see.

Can you please post the lockdep splat?

Thanks,
Richard

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
