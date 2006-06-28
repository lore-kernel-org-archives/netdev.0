From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 28 Jun 2006 20:02:26 +0200
Message-ID: <200606282002.26522.mb@bu3sch.de>
References: <20060626212547.GE30706@tuxdriver.com> <200606281832.01108.mb@bu3sch.de> <44A2BD36.3010601@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:12942
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750714AbWF1SC7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 14:02:59 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44A2BD36.3010601@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 28 June 2006 19:32, Larry Finger wrote:
> Michael Buesch wrote:
> > On Wednesday 28 June 2006 18:04, Larry Finger wrote:
> > 
> > Oh, well. Forget it all.
> > I remembered the code wrong.
> > At the moment I looked at the code and it has the opposite semantics.
> > It loops to wait for the READY bit to appear.
> > 
> > Well, I would say your old device simply takes this long
> > to disable and there is no bug.
> > 
> > Oh, well...
> 
> So the conclusion is that my card is really slow. As mine is likely to be the worst of the lot, I 
> propose the following structure for the loop in question:
> 
>                  for (i = 10000; i; i--) {
>                          tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
>                          if (tmp & BCM43xx_IRQ_READY) {
>                                  if (i < 9998)
>                                          printkl(KERN_INFO PFX "MAC suspend delay %d usec, IRQ_REASON "
>                                                  "0x%08x\n", 10000-i, tmp & ~BCM43xx_IRQ_READY);
>                                  goto out;
>                          }
>                          udelay(1);
>                  }
>                  printkl(KERN_ERR PFX "MAC suspend failed\n");
> 
> My maximum delay (so far) is 796 usec, thus this loop gives me a safety factor of more than 10, but 
> it should satisfy Jeff and let this patch in question be accepted.

Ok, I will send a patch to lower the limit to 10000 usec.
This won't do _any_ good (or bad), but well... If everybody likes
placebos, I will add it to the driver.

It's a bit complicated for me to say why your card takes 800usec
to suspend MAC. And additionally it is not really possible for
me to try to find a way making the card respond earlier (if possible)
remotely through you. ;)

How problematic might a 800usec delay with IRQs disabled be?

> Of course, the 'if (i < 9998)'  
> statement with the printkl is optional.

It is to be removed. ;)

-- 
Greetings Michael.
