From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] tg3: Convert u32 flag,flg2,flg3 uses to bitmap
Date: Thu, 21 Apr 2011 10:51:14 -0700
Message-ID: <1303408274.24766.66.camel@Joe-Laptop>
References: <1303322263-18991-10-git-send-email-mcarlson@broadcom.com>
	 <02bf2aa5c08514641ecbe7c39ef976918fad036c.1303367730.git.joe@perches.com>
	 <1303406280.8857.13.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matthew Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303406280.8857.13.camel@HP1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-04-21 at 10:18 -0700, Michael Chan wrote:
> On Wed, 2011-04-20 at 23:39 -0700, Joe Perches wrote:
> > @@ -4622,7 +4611,7 @@ static void tg3_tx_recover(struct tg3 *tp)
> >                     "and include system chipset information.\n");
> > 
> >         spin_lock(&tp->lock);
> > -       tp->tg3_flags |= TG3_FLAG_TX_RECOVERY_PENDING;
> > +       tg3_flag_set(tp, TX_RECOVERY_PENDING);
> >         spin_unlock(&tp->lock);
> >  }
> By using set_bit() now, we can eliminate the spin_lock() here.  This
> flag is checked much later when tg3_reset_task() is scheduled to run in
> workqueue, so no memory barrier is needed either.

Sure, but as a separate patch.
