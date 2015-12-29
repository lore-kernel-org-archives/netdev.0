From: Bjorn Andersson <bjorn@kryo.se>
Subject: Re: [PATCH 2/4] wcn36xx: Change indication list lock to spinlock
Date: Mon, 28 Dec 2015 20:25:10 -0800
Message-ID: <20151229042510.GI16437@tuxbot>
References: <1451266467-15377-1-git-send-email-bjorn.andersson@sonymobile.com>
 <1451266467-15377-3-git-send-email-bjorn.andersson@sonymobile.com>
 <20151228150635.79181f6e@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>, fengwei.yin@linaro.org,
	linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	wcn36xx@lists.infradead.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35624 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174AbbL2EZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 23:25:17 -0500
Received: by mail-pf0-f177.google.com with SMTP id 78so121196373pfw.2
        for <netdev@vger.kernel.org>; Mon, 28 Dec 2015 20:25:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151228150635.79181f6e@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon 28 Dec 15:06 PST 2015, Stephen Hemminger wrote:

> On Sun, 27 Dec 2015 17:34:25 -0800
> Bjorn Andersson <bjorn@kryo.se> wrote:
> 
> > In preparation for handling incoming messages from IRQ context, change
> > the indication list lock to a spinlock
> > 
> > Signed-off-by: Bjorn Andersson <bjorn.andersson@sonymobile.com>
> > ---
> >  drivers/net/wireless/ath/wcn36xx/smd.c     | 12 ++++++------
> >  drivers/net/wireless/ath/wcn36xx/wcn36xx.h |  2 +-
> >  2 files changed, 7 insertions(+), 7 deletions(-)
> > 
> > diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
> > index 6b5dbe6f0d0a..4307429740a9 100644
> > --- a/drivers/net/wireless/ath/wcn36xx/smd.c
> > +++ b/drivers/net/wireless/ath/wcn36xx/smd.c
> > @@ -2165,10 +2165,10 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
> >  		msg_ind->msg_len = len;
> >  		memcpy(msg_ind->msg, buf, len);
> >  
> > -		mutex_lock(&wcn->hal_ind_mutex);
> > +		spin_lock(&wcn->hal_ind_lock);
> 
> If you are going to handle messages in IRQ context, that better be a
> spin_lock_irq() or spin_lock_bh().

This function is executed in IRQ context after the next patch, as such I
use spin_lock() here and spin_lock_irqsave() in the worker thread
(wcn36xx_ind_smd_work()).

Is this not how the spin_lock API should be used?

Regards,
Bjorn
