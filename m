From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net-next 1/1] net: ipv4: Refine the ipv4_default_advmss
Date: Wed, 12 Apr 2017 10:33:22 +0800
Message-ID: <000601d2b335$28431810$78c94830$@foxmail.com>
References: <1491960999-42794-1-git-send-email-gfree.wind@foxmail.com> <1491962594.17839.28.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: "'Joe Perches'" <joe@perches.com>, <gfree.wind@foxmail.com>,
        <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbguseast2.qq.com ([54.204.34.130]:46265 "EHLO
        smtpbguseast2.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751605AbdDLCda (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 22:33:30 -0400
In-Reply-To: <1491962594.17839.28.camel@perches.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Wednesday, April 12, 2017 10:03 AM
> To: gfree.wind@foxmail.com; davem@davemloft.net; kuznet@ms2.inr.ac.ru;
> jmorris@namei.org; netdev@vger.kernel.org
> Cc: Gao Feng <fgao@ikuai8.com>
> Subject: Re: [PATCH net-next 1/1] net: ipv4: Refine the
ipv4_default_advmss
> 
> On Wed, 2017-04-12 at 09:36 +0800, gfree.wind@foxmail.com wrote:
> > From: Gao Feng <fgao@ikuai8.com>
> >
> > 1. Don't get the metric RTAX_ADVMSS of dst.
> > There are two reasons.
> > 1) Its caller dst_metric_advmss has already invoke dst_metric_advmss
> > before invoke default_advmss.
> > 2) The ipv4_default_advmss is used to get the default mss, it should
> > not try to get the metric like ip6_default_advmss.
> >
> > 2. Use sizeof(tcphdr)+sizeof(iphdr) instead of literal 40.
> >
> > 3. Define one new macro IPV4_MAX_PMTU instead of 65535 according to
> > RFC 2675, section 5.1.
> 
> trivia:
> 
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> []
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
> > +	advmss = min_t(unsigned int, advmss, IPV4_MAX_PMTU - header_size);
> 
> as all the elements are now unsigned int, the min_t cast seems
unnecessary.

Thanks, it is unnecessary to use min_t.
I have corrected it now.

Best Regards
Feng
