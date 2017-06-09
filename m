From: =?gb2312?B?uN+35Q==?= <fgao@ikuai8.com>
Subject: RE: [B.A.T.M.A.N.] [PATCH net] net: batman-adv: Fix possible memleaks when fail to register_netdevice
Date: Fri, 9 Jun 2017 15:26:26 +0800
Message-ID: <001a01d2e0f1$b529a070$1f7ce150$@ikuai8.com>
References: <1493121800-28066-1-git-send-email-gfree.wind@foxmail.com> <5895676.ebVRaD88im@bentobox>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: <gfree.wind@foxmail.com>, <mareklindner@neomailbox.ch>,
        <sw@simonwunderlich.de>, <a@unstable.cc>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
To: "'Sven Eckelmann'" <sven@narfation.org>,
        <b.a.t.m.a.n@lists.open-mesh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgbr2.qq.com ([54.207.22.56]:47807 "EHLO smtpbgbr2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751506AbdFIH0o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 03:26:44 -0400
In-Reply-To: <5895676.ebVRaD88im@bentobox>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Sven Eckelmann [mailto:sven@narfation.org]
> Sent: Friday, June 9, 2017 3:23 PM
> Subject: Re: [B.A.T.M.A.N.] [PATCH net] net: batman-adv: Fix possible
memleaks
> when fail to register_netdevice
> 
> On Dienstag, 25. April 2017 20:03:20 CEST gfree.wind@foxmail.com wrote:
> > From: Gao Feng <fgao@ikuai8.com>
> >
> > Because the func batadv_softif_init_late allocate some resources and
> > it would be invoked in register_netdevice. So we need to invoke the
> > func batadv_softif_free instead of free_netdev to cleanup when fail to
> > register_netdevice.
> >
> > Signed-off-by: Gao Feng <fgao@ikuai8.com>
> > ---
> >  net/batman-adv/soft-interface.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/net/batman-adv/soft-interface.c
> > b/net/batman-adv/soft-interface.c index d042c99..90bf990 100644
> > --- a/net/batman-adv/soft-interface.c
> > +++ b/net/batman-adv/soft-interface.c
> > @@ -1011,7 +1011,7 @@ struct net_device *batadv_softif_create(struct net
> *net, const char *name)
> >  	if (ret < 0) {
> >  		pr_err("Unable to register the batman interface '%s': %i\n",
> >  		       name, ret);
> > -		free_netdev(soft_iface);
> > +		batadv_softif_free(soft_iface);
> >  		return NULL;
> >  	}
> 
> It looks to me like this change is invalid after David's change [1]. Can
you
> confirm that?
> 
> Thanks,
> 	Sven
> 
> [1]
>
https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/?id=cf1
> 24db566e6b036b8bcbe8decbed740bdfac8c6
[Gao Feng] 

yes, this change is unnecessary. 

Best Regards
Feng
