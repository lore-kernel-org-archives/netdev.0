From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: NULL pointer dereference in rt6_get_cookie()
Date: Mon, 12 Oct 2015 13:31:16 -0700
Message-ID: <20151012203116.GC88112@canlin-mbp1.DHCP.thefacebook.com>
References: <20151010132437.GB25926@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:5550 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751999AbbJLUbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 16:31:40 -0400
Content-Disposition: inline
In-Reply-To: <20151010132437.GB25926@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 10, 2015 at 03:24:37PM +0200, Phil Sutter wrote:
> Using printk-debugging I could track down the problem to
> rt6_get_cookie() function in include/net/ip6_fib.h:
>
> The conditional at the start of the function evaluates true, since
> 'rt->rt6i_flags & RTF_PCPU' is non-zero. Due to that, 'rt' pointer is
> reassigned:
>
> | rt = (struct rt6_info *)(rt->dst.from);
>
> It appears that this effectively assigns NULL to it, and the following
> dereference causes the bug.
Thanks for the report.  I am looking into it.

--Martin
