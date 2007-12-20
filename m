From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [IPROUTE]: A workaround to make larger rto_min printed
 correctly
Date: Thu, 20 Dec 2007 17:35:36 +0900 (JST)
Message-ID: <20071220.173536.72554756.yoshfuji@linux-ipv6.org>
References: <d72b7ace0712191931w37f02645u8d5eb5eef9c1fba4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: satoru.satoh@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44186 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074AbXLTIfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 03:35:00 -0500
In-Reply-To: <d72b7ace0712191931w37f02645u8d5eb5eef9c1fba4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <d72b7ace0712191931w37f02645u8d5eb5eef9c1fba4@mail.gmail.com> (at Thu, 20 Dec 2007 12:31:27 +0900), "Satoru SATOH" <satoru.satoh@gmail.com> says:

> diff --git a/ip/iproute.c b/ip/iproute.c
> index f4200ae..fa722c6 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -510,16 +510,16 @@ int print_route(const struct sockaddr_nl *who,
> struct nlmsghdr *n, void *arg)
>                                 fprintf(fp, " %u",
> *(unsigned*)RTA_DATA(mxrta[i]));
>                         else {
>                                 unsigned val = *(unsigned*)RTA_DATA(mxrta[i]);
> +                               unsigned hz1 = hz / 1000;
> 
> -                               val *= 1000;
>                                 if (i == RTAX_RTT)

I think this is incorrect; hz might not be 1000; e.g. 250 etc.

--yoshfuji
