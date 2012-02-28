From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/2] ipv4: fix mss comparison
Date: Tue, 28 Feb 2012 10:34:26 +0100
Message-ID: <20120228093426.GA17057@electric-eye.fr.zoreil.com>
References: <1330417697-2637-1-git-send-email-roy.qing.li@gmail.com> <1330417697-2637-2-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41271 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752561Ab2B1Jec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Feb 2012 04:34:32 -0500
Content-Disposition: inline
In-Reply-To: <1330417697-2637-2-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

roy.qing.li@gmail.com <roy.qing.li@gmail.com> :
[...]
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 0489ced..c72f765 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1914,8 +1914,8 @@ static unsigned int ipv4_default_advmss(const struct dst_entry *dst)
>  	if (advmss == 0) {
>  		advmss = max_t(unsigned int, dst->dev->mtu - 40,
>  			       ip_rt_min_advmss);
> -		if (advmss > 65535 - 40)
> -			advmss = 65535 - 40;
> +		if (advmss > 65535 - sizeof(struct tcphdr))
> +			advmss = 65535 - sizeof(struct tcphdr);

What would prevent net/ipv4/tcp_output.c::tcp_advertise_mss returning
a value beyond 65535 - 40 ?

-- 
Ueimor
