From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net-next v2 1/1] net: ipv4: Refine the ipv4_default_advmss
Date: Wed, 12 Apr 2017 12:13:42 +0800
Message-ID: <000f01d2b343$2c603910$8520ab30$@foxmail.com>
References: <1491964333-69989-1-git-send-email-gfree.wind@foxmail.com> <1491969444.17839.30.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "'Gao Feng'" <fgao@ikuai8.com>
To: "'Joe Perches'" <joe@perches.com>, <davem@davemloft.net>,
        <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg65.qq.com ([103.7.28.233]:39121 "EHLO smtpbg65.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751181AbdDLEOG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 00:14:06 -0400
In-Reply-To: <1491969444.17839.30.camel@perches.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Joe Perches
> Sent: Wednesday, April 12, 2017 11:57 AM
> To: gfree.wind@foxmail.com; davem@davemloft.net; kuznet@ms2.inr.ac.ru;
> jmorris@namei.org; netdev@vger.kernel.org
> Cc: Gao Feng <fgao@ikuai8.com>
> Subject: Re: [PATCH net-next v2 1/1] net: ipv4: Refine the
ipv4_default_advmss
> 
> On Wed, 2017-04-12 at 10:32 +0800, gfree.wind@foxmail.com wrote:
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> 
> more trivia:
> 
> > @@ -1250,14 +1250,11 @@ static void set_class_tag(struct rtable *rt,
> > u32 tag)
> >
> >  static unsigned int ipv4_default_advmss(const struct dst_entry *dst)
> > {
> > -	unsigned int advmss = dst_metric_raw(dst, RTAX_ADVMSS);
> > +	unsigned int header_size = sizeof(struct tcphdr) + sizeof(struct
iphdr);
> > +	unsigned int advmss = max_t(unsigned int, dst->dev->mtu -
header_size,
> > +				    ip_rt_min_advmss);
> >
> > -	if (advmss == 0) {
> > -		advmss = max_t(unsigned int, dst->dev->mtu - 40,
> > -			       ip_rt_min_advmss);
> > -		if (advmss > 65535 - 40)
> > -			advmss = 65535 - 40;
> > -	}
> > +	advmss = min(advmss, IPV4_MAX_PMTU - header_size);
> >  	return advmss;
> >  }
> 
> This would probably be simpler to read as:
> 
> 	return min(advmss, IPV4_MAX_PMTU - header_size);
> 
> though it's almost certain that the compiler emits identical object code.

Yes. I thought about writing it with the way you mentioned, but gave up.
But i could follow you this time.

Best Regards
Feng
