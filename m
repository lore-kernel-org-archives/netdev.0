From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [BUG ?] delay always evaluates to 0
Date: Mon, 15 Jun 2015 19:38:25 +0200
Message-ID: <20150615173825.GC31859@opentech.at>
References: <20150612165829.GA22474@opentech.at> <CA++WF2NoEAhRKnOXtC_C=JfmvZU=WuPEKZ3Zs2KxdHwBtHhHFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA++WF2NoEAhRKnOXtC_C=JfmvZU=WuPEKZ3Zs2KxdHwBtHhHFg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Jun 2015, Stanislav Yakovlev wrote:

> Hi Nicholas,
> 
> On 12 June 2015 at 20:58, Nicholas Mc Guire <der.herr@hofr.at> wrote:
> > Hi !
> >
> > commit 2c86c275015c ("Add ipw2100 wireless driver.") introduced
> >
> > drivers/net/wireless/ipw2100.c - line-numbers are from next-20150511
> > 1410 static int ipw2100_hw_phy_off(struct ipw2100_priv *priv)
> > 1411 {
> > 1412
> > 1413 #define HW_PHY_OFF_LOOP_DELAY (HZ / 5000)
> > 1414
> > ...
> > 1437
> > 1438                 schedule_timeout_uninterruptible(HW_PHY_OFF_LOOP_DELAY);
> > 1439         }
> >
> > but (HZ / 5000) will evaluate to 0 for all configurable HZ values - typo ?
> > and this schedule_timeout_uninterruptible() is probably not doing what
> > is intended.
> 
> Yes, you are right. This is a bug. I think it should be:
> 
> -#define HW_PHY_OFF_LOOP_DELAY (HZ / 5000)
> +#define HW_PHY_OFF_LOOP_DELAY (msecs_to_jiffies(50))
> 
> Will you send us a patch?
>
just sent it out - thanks!

hofrat 
