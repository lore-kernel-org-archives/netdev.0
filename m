From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: fix unexpected LED control values in BCM4303
	sprom
Date: Tue, 31 Oct 2006 22:49:42 -0500
Message-ID: <20061101034936.GD9309@tuxdriver.com>
References: <4535AFC2.mail3S81JGSDJ@lwfinger.net>
	<200610181637.08698.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200610181637.08698.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2006 at 04:37:08PM +0200, Michael Buesch wrote:

> > @@ -257,7 +263,11 @@ void bcm43xx_leds_update(struct bcm43xx_
> >  			continue;
> >  #endif /* CONFIG_BCM43XX_DEBUG */
> >  		default:
> > -			assert(0);
> > +			if (bcm43xx_max_led_err) {
> > +				printkl(KERN_INFO PFX "Bad value in leds_update,"
> > +					" led->behaviour: 0x%x\n", led->behaviour);
> > +				--bcm43xx_max_led_err;
> > +			}
> 
> I'd call this message bloat. ;) This is the first time the assertion
> triggers since it was added.
> You could instead remove the assert(), remove bcm43xx_max_led_err
> and use dprintkl instead of printkl.
> 
> >  		};
> >  
> >  		if (led->activelow)
> > Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_leds.h
> > ===================================================================
> > --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_leds.h
> > +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_leds.h
> > @@ -24,6 +24,10 @@ struct bcm43xx_led {
> >  
> >  #define BCM43xx_LED_BEHAVIOUR		0x7F
> >  #define BCM43xx_LED_ACTIVELOW		0x80
> > +#define BCM43xx_LED_BCM4303_0		0x2B
> > +#define BCM43xx_LED_BCM4303_1		0x78
> > +#define BCM43xx_LED_BCM4303_2		0x2E
> > +#define BCM43xx_LED_BCM4303_3		0x19
> 
> Add these to the enum below, instead, please.
> The defines above are masks and not the behaviour values.
> 
> >  enum { /* LED behaviour values */
> >  	BCM43xx_LED_OFF,
> >  	BCM43xx_LED_ON,

I took Michael's suggestions before merging your patch...FYI! :-)

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
