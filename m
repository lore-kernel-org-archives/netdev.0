From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net 1/5] macsec: add missing NULL check after kmalloc
Date: Tue, 19 Apr 2016 22:25:21 +0200
Message-ID: <20160419202521.GA1297@bistromath.localdomain>
References: <cover.1460967681.git.sd@queasysnail.net>
 <cover.1460967681.git.sd@queasysnail.net>
 <c986bb2421c817eeb00416bd2055f69040924af5.1460967681.git.sd@queasysnail.net>
 <1625750535.15145234.1461087947312.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754512AbcDSUZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 16:25:26 -0400
Content-Disposition: inline
In-Reply-To: <1625750535.15145234.1461087947312.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-04-19, 13:45:47 -0400, Lance Richardson wrote:
> ----- Original Message -----
> > From: "Sabrina Dubroca" <sd@queasysnail.net>
> > To: netdev@vger.kernel.org
> > Cc: "Hannes Frederic Sowa" <hannes@stressinduktion.org>, "Johannes Berg" <johannes@sipsolutions.net>, "Dan Carpenter"
> > <dan.carpenter@oracle.com>, "Sabrina Dubroca" <sd@queasysnail.net>
> > Sent: Tuesday, April 19, 2016 1:36:38 PM
> > Subject: [PATCH net 1/5] macsec: add missing NULL check after kmalloc
> > 
> > Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
> > Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >  drivers/net/macsec.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
> > index 84d3e5ca8817..f691030ee3df 100644
> > --- a/drivers/net/macsec.c
> > +++ b/drivers/net/macsec.c
> > @@ -1622,8 +1622,8 @@ static int macsec_add_rxsa(struct sk_buff *skb, struct
> > genl_info *info)
> >  	}
> >  
> >  	rx_sa = kmalloc(sizeof(*rx_sa), GFP_KERNEL);
> > -	if (init_rx_sa(rx_sa, nla_data(tb_sa[MACSEC_SA_ATTR_KEY]), secy->key_len,
> > -		       secy->icv_len)) {
> > +	if (!rx_sa || init_rx_sa(rx_sa, nla_data(tb_sa[MACSEC_SA_ATTR_KEY]),
> > +				 secy->key_len, secy->icv_len)) {
> 
> Doesn't this leak rx_sa if kmalloc() succeeds but init_rx_sa fails?

Yeah, you're right.  And there's the same code around init_tx_sa.
I'll send v2 tomorrow with this and another fix.

Thanks!

> >  		rtnl_unlock();
> >  		return -ENOMEM;
> >  	}
> > --
> > 2.8.0
> > 
> > 

-- 
Sabrina
