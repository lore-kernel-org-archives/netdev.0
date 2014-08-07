From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 3/5] drivers/atm/atmtcp.c: fix error return code
Date: Thu, 7 Aug 2014 15:25:46 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1408071525280.2337@hadrien>
References: <1407415749-19978-1-git-send-email-Julia.Lawall@lip6.fr> <1407415749-19978-3-git-send-email-Julia.Lawall@lip6.fr> <20140807091012.793ef5c7@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140807091012.793ef5c7@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Aug 2014, chas williams - CONTRACTOR wrote:

> On Thu,  7 Aug 2014 14:49:06 +0200
> Julia Lawall <Julia.Lawall@lip6.fr> wrote:
>
> > From: Julia Lawall <Julia.Lawall@lip6.fr>
> >
> > Convert a zero return value on error to a negative one, as returned
> > elsewhere in the function.
> >
> > A simplified version of the semantic match that finds this problem is as
> > follows: (http://coccinelle.lip6.fr/)
> ...
> >
> > diff --git a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
> > index 0e3f8f9..c8e4fb4 100644
> > --- a/drivers/atm/atmtcp.c
> > +++ b/drivers/atm/atmtcp.c
> > @@ -299,6 +299,7 @@ static int atmtcp_c_send(struct atm_vcc *vcc,struct sk_buff *skb)
> >  	out_vcc = find_vcc(dev, ntohs(hdr->vpi), ntohs(hdr->vci));
> >  	read_unlock(&vcc_sklist_lock);
> >  	if (!out_vcc) {
> > +		result = -ESRCH;
>
> This should probably be -EUNATCH to match the rest of the code.

Thanks.  I will send a new version.

julia

> >  		atomic_inc(&vcc->stats->tx_err);
> >  		goto done;
> >  	}
> >
>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
