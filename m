From: Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] ath9k: Add cast to u8 to FREQ2FBIN macro
Date: Thu, 6 Apr 2017 16:54:27 -0700
Message-ID: <20170406235427.GC78690@google.com>
References: <20170406212135.72157-1-mka@chromium.org>
 <1491514160.27353.102.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1491514160.27353.102.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Joe,

El Thu, Apr 06, 2017 at 02:29:20PM -0700 Joe Perches ha dit:

> On Thu, 2017-04-06 at 14:21 -0700, Matthias Kaehlcke wrote:
> > The macro results are assigned to u8 variables/fields. Adding the cast
> > fixes plenty of clang warnings about "implicit conversion from 'int' to
> > 'u8'".
> > 
> > Signed-off-by: Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> > ---
> >  drivers/net/wireless/ath/ath9k/eeprom.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/wireless/ath/ath9k/eeprom.h b/drivers/net/wireless/ath/ath9k/eeprom.h
> > index 30bf722e33ed..31390af6c33e 100644
> > --- a/drivers/net/wireless/ath/ath9k/eeprom.h
> > +++ b/drivers/net/wireless/ath/ath9k/eeprom.h
> > @@ -106,7 +106,7 @@
> >  #define AR9285_RDEXT_DEFAULT    0x1F
> >  
> >  #define ATH9K_POW_SM(_r, _s)	(((_r) & 0x3f) << (_s))
> > -#define FREQ2FBIN(x, y)		((y) ? ((x) - 2300) : (((x) - 4800) / 5))
> > +#define FREQ2FBIN(x, y)		(u8)((y) ? ((x) - 2300) : (((x) - 4800) / 5))
> 
> Maybe better to use:
> 
> static inline u8 FREQ2FBIN(int x, int y)
> {
> 	if (y)
> 		return x - 2300;
> 	return (x - 4800) / 5;
> }

Thanks for your suggestion! Unfortunately in this case an inline
function is not suitable since FREQ2FBIN() is mostly used for
structure initialization:

static const struct ar9300_eeprom ar9300_default = {
...
        .calFreqPier2G = {
                FREQ2FBIN(2412, 1),
                FREQ2FBIN(2437, 1),
                FREQ2FBIN(2472, 1),
        },
...

Cheers

Matthias
