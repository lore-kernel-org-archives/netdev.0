From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCHv3 6/6] drivers/staging/rtl8821ae: replace magic number
 by macro
Date: Tue, 24 Jun 2014 17:52:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406241748040.22030@chino.kir.corp.google.com>
References: <1403561511-8117-1-git-send-email-rickard_strandqvist@spectrumdigital.se> <1455413.BevQxGKhmu@al>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Wu <peter@lekensteyn.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455413.BevQxGKhmu@al>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Jun 2014, Peter Wu wrote:

> (staging drivers are handled by Greg KH, cc'ing him)
> 
> On Tuesday 24 June 2014 00:11:51 Rickard Strandqvist wrote:
> > For consistency with other drivers, replace a magic number by a macro.
> > 
> > Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> > Reviewed-by: Peter Wu <peter@lekensteyn.nl>
> > ---
> >  drivers/staging/rtl8821ae/rtl8821ae/hw.c  |    2 +-
> >  drivers/staging/rtl8821ae/rtl8821ae/reg.h |    1 +
> >  2 files changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/staging/rtl8821ae/rtl8821ae/hw.c b/drivers/staging/rtl8821ae/rtl8821ae/hw.c
> > index 1b8583b..1aa1661 100644
> > --- a/drivers/staging/rtl8821ae/rtl8821ae/hw.c
> > +++ b/drivers/staging/rtl8821ae/rtl8821ae/hw.c
> > @@ -1623,7 +1623,7 @@ static int _rtl8821ae_set_media_status(struct ieee80211_hw *hw,
> >  
> >  	rtl_write_byte(rtlpriv, (MSR), bt_msr);
> >  	rtlpriv->cfg->ops->led_control(hw, ledaction);
> > -	if ((bt_msr & ~0xfc) == MSR_AP)
> > +	if ((bt_msr & MSR_MASK) == MSR_AP)
> >  		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
> >  	else
> >  		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
> > diff --git a/drivers/staging/rtl8821ae/rtl8821ae/reg.h b/drivers/staging/rtl8821ae/rtl8821ae/reg.h
> > index beffb42..4cb3ca9 100644
> > --- a/drivers/staging/rtl8821ae/rtl8821ae/reg.h
> > +++ b/drivers/staging/rtl8821ae/rtl8821ae/reg.h
> > @@ -431,6 +431,7 @@
> >  #define	MSR_ADHOC					0x01
> >  #define	MSR_INFRA					0x02
> >  #define	MSR_AP						0x03
> > +#define	MSR_MASK					0x03
> >  
> >  #define	RRSR_RSC_OFFSET				21
> >  #define	RRSR_SHORT_OFFSET			23

Doing this certainly is better than the old code, but if you're going to 
add an MSR_MASK I think it would be better to define it and move all of 
these MSR_* bits to a generalized bit/wireless/rtlwifi header since they 
all need it and there's no changes between them.

Notice how much of this handling is already wrong where rtlwifi drivers 
are checking for bt_msr & 0xfc == MSR_AP which is obviously an impossible 
condition, and those aren't even staging drivers.

A cleanup in this area would be most helpful.
