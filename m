From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Fix allocation of cong control alg name
Date: Wed, 24 Jun 2015 23:31:19 -0400
Message-ID: <20150624233119.4f6e3a72@uryu.home.lan>
References: <1432895400-12266-1-git-send-email-vadim4j@gmail.com>
	<556848F4.6080003@iogearbox.net>
	<F15B4449A1150D418551CFE4D16B783B86469FBC@FMSMSX102.amr.corp.intel.com>
	<5568986A.7010000@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Guzman Mosqueda, Jose R" <jose.r.guzman.mosqueda@intel.com>,
	Vadim Kochan <vadim4j@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	eric.dumazet@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35059 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbbFYDbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 23:31:22 -0400
Received: by qkbp125 with SMTP id p125so32331547qkb.2
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2015 20:31:21 -0700 (PDT)
In-Reply-To: <5568986A.7010000@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 May 2015 18:48:42 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 05/29/2015 06:17 PM, Guzman Mosqueda, Jose R wrote:
> > Hi Daniel and Vadim
> >
> > Thanks for your prompt response and for the patch.
> >
> > Also, what about the other one? Do you think it is an issue or not?
> >
> > " File: tc/tc_util.c
> > Function: void print_rate(char *buf, int len, __u64 rate)
> > Line: ~264
> >
> > In the case that user inputs a high value for rate, the "for" loop will exit in the condition meaning that variable "i" get the value of 5 which will be an invalid index for the "units" array due to that array has only 5 elements."
> >
> > I know a very high value is invalid but in the case that it comes directly from user, it could cause and issue, what do you think?
> 
> Hm, this prints just the netlink dump from kernel side, but perhaps
> we should just change it ...
> 
> diff --git a/tc/tc_util.c b/tc/tc_util.c
> index dc2b70f..aa6de24 100644
> --- a/tc/tc_util.c
> +++ b/tc/tc_util.c
> @@ -250,18 +250,19 @@ void print_rate(char *buf, int len, __u64 rate)
>   	extern int use_iec;
>   	unsigned long kilo = use_iec ? 1024 : 1000;
>   	const char *str = use_iec ? "i" : "";
> -	int i = 0;
>   	static char *units[5] = {"", "K", "M", "G", "T"};
> +	int i;
> 
>   	rate <<= 3; /* bytes/sec -> bits/sec */
> 
> -	for (i = 0; i < ARRAY_SIZE(units); i++)  {
> +	for (i = 0; i < ARRAY_SIZE(units) - 1; i++)  {
>   		if (rate < kilo)
>   			break;
>   		if (((rate % kilo) != 0) && rate < 1000*kilo)
>   			break;
>   		rate /= kilo;
>   	}
> +
>   	snprintf(buf, len, "%.0f%s%sbit", (double)rate, units[i], str);
>   }

I don't know what thread you meant to hijack for this, but it wasn't the
one about ss: cong name.
