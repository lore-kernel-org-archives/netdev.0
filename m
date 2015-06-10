From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 1/1 linux-next] ath5k: use swap() in
 ath5k_hw_get_median_noise_floor()
Date: Wed, 10 Jun 2015 22:29:18 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1506102228560.1986@localhost6.localdomain6>
References: <1433954015-24872-1-git-send-email-fabf@skynet.be> <1433965966.32331.25.camel@perches.com> <1121998377.24127.1433966378845.open-xchange@webmail.nmp.proximus.be>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-224748411-1433968160=:1986"
Cc: Joe Perches <joe@perches.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	linux-wireless@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>
To: Fabian Frederick <fabf@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:33320 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754386AbbFJU3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 16:29:21 -0400
In-Reply-To: <1121998377.24127.1433966378845.open-xchange@webmail.nmp.proximus.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-224748411-1433968160=:1986
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT



On Wed, 10 Jun 2015, Fabian Frederick wrote:

> 
> 
> > On 10 June 2015 at 21:52 Joe Perches <joe@perches.com> wrote:
> >
> >
> > On Wed, 2015-06-10 at 18:33 +0200, Fabian Frederick wrote:
> > > Use kernel.h macro definition.
> > >
> > > Thanks to Julia Lawall for Coccinelle scripting support.
> > []
> > > diff --git a/drivers/net/wireless/ath/ath5k/phy.c
> > > b/drivers/net/wireless/ath/ath5k/phy.c
> > []
> > > @@ -1566,17 +1566,13 @@ static s16
> > >  ath5k_hw_get_median_noise_floor(struct ath5k_hw *ah)
> > >  {
> > >     s16 sort[ATH5K_NF_CAL_HIST_MAX];
> > > -   s16 tmp;
> > >     int i, j;
> > > 
> > >     memcpy(sort, ah->ah_nfcal_hist.nfval, sizeof(sort));
> > >     for (i = 0; i < ATH5K_NF_CAL_HIST_MAX - 1; i++) {
> > >             for (j = 1; j < ATH5K_NF_CAL_HIST_MAX - i; j++) {
> > > -                   if (sort[j] > sort[j - 1]) {
> > > -                           tmp = sort[j];
> > > -                           sort[j] = sort[j - 1];
> > > -                           sort[j - 1] = tmp;
> > > -                   }
> > > +                   if (sort[j] > sort[j - 1])
> > > +                           swap(sort[j], sort[j]);
> >
> > swap(a, a) doesn't look useful.
> Thanks a lot Joe, I'll fix this one :)

How did it come out like that?

julia

> 
> Regards,
> Fabian
> >
> >
> 
--8323328-224748411-1433968160=:1986--
