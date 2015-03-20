From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix tcp fin memory accounting
Date: Thu, 19 Mar 2015 19:17:26 -0700
Message-ID: <1426817846.25985.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426807170-19258-1-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:36535 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbbCTCRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 22:17:25 -0400
Received: by iedm5 with SMTP id m5so18085960ied.3
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 19:17:24 -0700 (PDT)
In-Reply-To: <1426807170-19258-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-19 at 19:19 -0400, Josh Hunt wrote:
> tcp_send_fin() does not account for the memory it allocates properly, so
> sk_forward_alloc can be negative in cases where we've sent a FIN:
> 
> ss example output (ss -amn | grep -B1 f4294):
> tcp    FIN-WAIT-1 0      1            192.168.0.1:45520         192.0.2.1:8080
> 	skmem:(r0,rb87380,t0,tb87380,f4294966016,w1280,o0,bl0)
> --
> tcp    FIN-WAIT-1 0      1            192.168.0.1:8080          192.0.2.1:59710
> 	skmem:(r0,rb87380,t0,tb87380,f4294966016,w1280,o0,bl0)
> 
> This can be resolved by using sk_stream_alloc_skb() instead of calling alloc_skb_fclone()
> directly. The same fix was made in tcp_connect() in commit 355a901e6cf1 (tcp: make connect() mem charging friendly).
> 
> With this fix applied I no longer see the negative sk_forward_alloc values (or
> very large values repoted by ss) in my tests.
> 
> Signed-off-by: Josh Hunt <johunt@akamai.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
