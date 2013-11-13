From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: tsq: restore minimal amount of queueing
Date: Wed, 13 Nov 2013 06:06:35 -0800
Message-ID: <1384351595.28458.98.camel@edumazet-glaptop2.roam.corp.google.com>
References: <8761s0cqhh.fsf@natisbad.org>
	 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	 <87y54u59zq.fsf@natisbad.org>
	 <1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Sujith Manoharan <sujith@msujith.org>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:59902 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530Ab3KMOGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 09:06:37 -0500
Received: by mail-pd0-f172.google.com with SMTP id q10so455259pdj.3
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 06:06:36 -0800 (PST)
In-Reply-To: <1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-12 at 06:39 -0800, Eric Dumazet wrote:

> -		limit = max(skb->truesize, sk->sk_pacing_rate >> 10);
> +		limit = max(sysctl_tcp_limit_output_bytes,
> +			    sk->sk_pacing_rate >> 10);
>  


I'll send a v2, a max_t(unsigned int, ..., ...) is needed here,
as reported by kbuild bot.

net/ipv4/tcp_output.c:1882:177: warning: comparison of distinct pointer
types lacks a cast [enabled by default]
