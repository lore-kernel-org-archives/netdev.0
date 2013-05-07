From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] gre: verify packet before using inner header
Date: Tue, 07 May 2013 06:18:35 -0700
Message-ID: <1367932715.13473.3.camel@edumazet-glaptop>
References: <1367914850-11055-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:52928 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754771Ab3EGNSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 09:18:40 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so392595pbc.35
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 06:18:39 -0700 (PDT)
In-Reply-To: <1367914850-11055-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-07 at 16:20 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> We use ->h_proto of the inner mac header before calling
> pskb_may_pull() to verify the length of the packet.
> This might not be a problem, but at least we'd better
> error out as early as possible.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
> index cc22363..8a90c67 100644
> --- a/net/ipv4/gre.c
> +++ b/net/ipv4/gre.c
> @@ -149,6 +149,9 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>  	} else
>  		csum = false;
>  
> +	if (unlikely(!pskb_may_pull(skb, ghl)))
> +		goto out;
> +

No, you're adding yet another bug [1]

If you are not sure you fix one, just forget this patch.

[1] Check commits :
d14a489a411937fb9420fe2b05168ee9e1e06c9c
22251c73ca63b5b1050724be9b54910c101a5f30
96af69ea2a83d292238bdba20e4508ee967cf8cb
1b05c4b50edbddbdde715c4a7350629819f6655e
ab43ed8b7490cb387782423ecf74aeee7237e591
9cb429d692b341e972b12e6cd097364050ebbb26
