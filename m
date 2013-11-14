From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] htb: support 64bit rates
Date: Thu, 14 Nov 2013 06:28:57 -0800
Message-ID: <1384439337.28458.145.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384295647.28458.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <528485D0.5030300@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:44446 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909Ab3KNO3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 09:29:00 -0500
Received: by mail-pa0-f54.google.com with SMTP id lj1so2168834pab.27
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 06:28:59 -0800 (PST)
In-Reply-To: <528485D0.5030300@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 16:12 +0800, Yang Yingliang wrote:
> On 2013/11/13 6:34, Eric Dumazet wrote:
> 
> [...]
> > @@ -256,6 +270,7 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
> >  	struct tc_htb_glob *gopt;
> >  	double buffer,cbuffer;
> >  	unsigned int linklayer;
> > +	__u64 rate64, ceil64;
> >  	SPRINT_BUF(b1);
> >  	SPRINT_BUF(b2);
> >  	SPRINT_BUF(b3);
> > @@ -275,12 +290,25 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
> >  			if (show_details)
> >  				fprintf(f, "quantum %d ", (int)hopt->quantum);
> >  		}
> > -		fprintf(f, "rate %s ", sprint_rate(hopt->rate.rate, b1));
> > +
> > +		rate64 = hopt->rate.rate;
> > +		if (tb[TCA_HTB_RATE64] &&
> > +		    RTA_PAYLOAD(tb[TCA_HTB_RATE64]) >= sizeof(rate64)) {
> > +			rate64 = rta_getattr_u64(tb[TCA_HTB_RATE64]);
> > +		}
> > +
> 
> If RTA_PAYLOAD(tb[TCA_HTB_RATE64]) < sizeof(rate64),
> it means something wrong, it don't need to continue,
> "return -1" would be better.

Nothing wrong actually.

Checking for these conditions are absolutely normal, to maintain
compatibility between old/new tc and or kernels.
