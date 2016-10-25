From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] cw1200: fix bogus maybe-uninitialized warning
Date: Tue, 25 Oct 2016 22:19:49 +0200
Message-ID: <14428343.0Jf5tZk0Ep@wuerfel>
References: <20161024154215.2863586-1-arnd@arndb.de> <063D6719AE5E284EB5DD2968C1650D6DB0209E9A@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Solomon Peachy <pizza@shaftnet.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        Johannes Berg <johannes.berg@intel.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0209E9A@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, October 25, 2016 1:24:55 PM CEST David Laight wrote:
> > diff --git a/drivers/net/wireless/st/cw1200/wsm.c b/drivers/net/wireless/st/cw1200/wsm.c
> > index 680d60eabc75..094e6637ade2 100644
> > --- a/drivers/net/wireless/st/cw1200/wsm.c
> > +++ b/drivers/net/wireless/st/cw1200/wsm.c
> > @@ -385,14 +385,13 @@ static int wsm_multi_tx_confirm(struct cw1200_common *priv,
> >       if (WARN_ON(count <= 0))
> >               return -EINVAL;
> > 
> > -     if (count > 1) {
> > -             /* We already released one buffer, now for the rest */
> > -             ret = wsm_release_tx_buffer(priv, count - 1);
> > -             if (ret < 0)
> > -                     return ret;
> > -             else if (ret > 0)
> > -                     cw1200_bh_wakeup(priv);
> > -     }
> > +     /* We already released one buffer, now for the rest */
> > +     ret = wsm_release_tx_buffer(priv, count - 1);
> > +     if (ret < 0)
> > +             return ret;
> > +
> > +     if (ret > 0)
> > +             cw1200_bh_wakeup(priv);
> 
> That doesn't look equivalent to me (when count == 1).

Ah, that's what I missed, thanks for pointing that out!

> > 
> >       cw1200_debug_txed_multi(priv, count);
> >       for (i = 0; i < count; ++i) {
> 
> Convert this loop into a do ... while so the body executes at least once.

Good idea. Version 2 coming now.

	Arnd
