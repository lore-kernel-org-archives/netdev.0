From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4 4/5] vxlan: add scope_id support for ll addr
Date: Fri, 19 Apr 2013 19:56:15 +0800
Message-ID: <1366372575.5117.20.camel@cr0>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	 <1366175423-27310-5-git-send-email-amwang@redhat.com>
	 <OFA1761298.DF396ECD-ON85257B52.003AE2CA-85257B52.003DBDAB@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16534 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968123Ab3DSL43 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 07:56:29 -0400
In-Reply-To: <OFA1761298.DF396ECD-ON85257B52.003AE2CA-85257B52.003DBDAB@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 07:14 -0400, David Stevens wrote:
> Cong Wang <amwang@redhat.com> wrote on 04/17/2013 01:10:21 AM:
>  
> > diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> > index 43ed40f..531c5e2 100644
> > --- a/drivers/net/vxlan.c
> > +++ b/drivers/net/vxlan.c
> > @@ -92,9 +92,10 @@ struct vxlan_addr {
> >        struct sockaddr_in6   sin6;
> >        struct sockaddr      sa;
> >     } u;
> > -#define va_sin  u.sin.sin_addr.s_addr
> > -#define va_sin6 u.sin6.sin6_addr
> > -#define va_sa   u.sa.sa_family
> > +#define va_sin      u.sin.sin_addr.s_addr
> > +#define va_sin6      u.sin6.sin6_addr
> > +#define va_scope_id   u.sin6.sin6_scope_id
> > +#define va_sa      u.sa.sa_family
> >  };
> 
>         As I commented before, you're obscuring the types here,
> which makes it less readable. "va_sin6" ought to be a sockaddr_in6,
> not a sin6_addr, and the scope id ought to then be 
> "va_sin6.sin6_scope_id",
> without any other #define necessary for it.

OK, so #define va_sin6  u.sin6?

> 
>         So, no, I don't think this patch is correct or complete.
> 

Then let's defer it, I need more time to make it working. I will discard
the scope_id patch for now, and make a correct one later.

Thanks.
