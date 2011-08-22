From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 4/4] drivers/net/wireless/mwifiex/scan.c: test the
 just-initialized value
Date: Mon, 22 Aug 2011 17:28:12 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1108221727470.10948@ask.diku.dk>
References: <1314021636-11528-4-git-send-email-julia@diku.dk>
 <4E527394.4080900@lwfinger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bing Zhao <bzhao@marvell.com>, kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:37756 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752598Ab1HVP20 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Aug 2011 11:28:26 -0400
In-Reply-To: <4E527394.4080900@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Aug 2011, Larry Finger wrote:

> On 08/22/2011 09:00 AM, Julia Lawall wrote:
> > From: Julia Lawall<julia@diku.dk>
> >
> > Test the just-initialized value rather than some other one.
> >
> > The semantic match that finds this problem is as follows:
> > (http://coccinelle.lip6.fr/)
> >
> > //<smpl>
> > @r@
> > identifier x,y,f!={PTR_ERR,ERR_PTR,ERR_CAST};
> > statement S;
> > @@
> >
> > x = f(...);
> > (
> > if (\(x == NULL\|IS_ERR(x)\)) S
> > |
> > *if (\(y == NULL\|IS_ERR(y)\))
> >   { ... when != x
> >     return ...; }
> > )
> > //</smpl>
> >
> > Signed-off-by: Julia Lawall<julia@diku.dk>
> >
> > ---
> >   drivers/net/wireless/mwifiex/scan.c |    2 +-
> >   1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/drivers/net/wireless/mwifiex/scan.c
> > b/drivers/net/wireless/mwifiex/scan.c
> > index b28241c..d3111c9 100644
> > --- a/drivers/net/wireless/mwifiex/scan.c
> > +++ b/drivers/net/wireless/mwifiex/scan.c
> > @@ -1480,7 +1480,7 @@ mwifiex_update_curr_bss_params(struct mwifiex_private
> > *priv,
> >    	return -ENOMEM;
> >    }
> >    beacon_ie = kzalloc(ie_len, GFP_KERNEL);
> > -	if (!bss_desc) {
> > +	if (!beacon_ie) {
> >     dev_err(priv->adapter->dev, " failed to alloc bss_desc\n");
> >     return -ENOMEM;
> >    }
> 
> The error message should also get the bss_desc => beacon_ie chang.

Thanks.  Pierre Louis Aublin made the same observation and I resumitted 
the patch.

julia
