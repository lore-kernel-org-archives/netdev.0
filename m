From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] 3c507.c: remove unused NULL pointer check
Date: Mon, 21 Dec 2009 12:31:11 -0800
Message-ID: <20091221123111.4498b17c@nehalam>
References: <200912211923.58735.strakh@ispras.ru>
	<4B2FA8C7.3010509@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Strakh <strakh@ispras.ru>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Donald Becker <becker@scyld.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757026AbZLUUbY@vger.kernel.org>
In-Reply-To: <4B2FA8C7.3010509@hartkopp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Dec 2009 17:56:39 +0100
Oliver Hartkopp <socketcan@hartkopp.net> wrote:

> Alexander Strakh wrote:
> > 	In driver drivers/net/3c507.c in function Iirqreturn_t el16_interrupt:
> > 1. If in line 555 dev = NULL then we goto line 556
> > 2. In line 556 we have null dereference because pr_err called with dev->name 
> > in third parameter.
> >  555        if (dev == NULL) {
> >  556                pr_err("%s: net_interrupt(): irq %d for unknown device.
> > \n",
> >  557                        dev->name, irq);
> >  558                return IRQ_NONE;
> >  559        }
> > 
> > Found by Linux Device Drivers Verification (Svace detector)
> > 
> > Remove unused NULL pointer check.
> 
> You are obviously doing more than that ...
> 
> > 
> > Signed-off-by: Alexander Strakh <strakh@ispras.ru>
> > 
> > ---
> > diff --git a/./0000/drivers/net/3c507.c b/./moder/drivers/net/3c507.c
> > index fbc2311..3bfb3dd 100644
> > --- a/./0000/drivers/net/3c507.c
> > +++ b/./moder/drivers/net/3c507.c
> > @@ -552,12 +552,6 @@ static irqreturn_t el16_interrupt(int irq, void *dev_id)
> >  	ushort ack_cmd = 0;
> >  	void __iomem *shmem;
> >  
> > -	if (dev == NULL) {
> > -		pr_err("%s: net_interrupt(): irq %d for unknown device.\n",
> > -			dev->name, irq);
> 
> You are changing real funcionality here!
> 
> If you want to fix it, fix the pr_err() but do not remove the "return
> IRQ_NONE" entirely.
> 
> This looks like an introduction of a bug.
> 
> Regards,
> Oliver
> 
> 
> > -		return IRQ_NONE;
> > -	}
> > -

Interrupts will never be called with third parameter of NULL. It is really
bogus impossible to reach code.

-- 
