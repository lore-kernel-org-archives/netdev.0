From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] net: add RCU annotation to sk_dst_cache field
Date: Tue, 22 Jan 2013 20:50:59 -0800
Message-ID: <1358916659.12374.684.camel@edumazet-glaptop>
References: <1358916229-19004-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:44584 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872Ab3AWEvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 23:51:03 -0500
Received: by mail-pb0-f52.google.com with SMTP id ro2so4452708pbb.39
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 20:51:02 -0800 (PST)
In-Reply-To: <1358916229-19004-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 12:43 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> sock->sk_dst_cache is protected by RCU.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 5a34e2f..c4b64c6 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -337,7 +337,7 @@ struct sock {
>  #endif
>  	unsigned long 		sk_flags;
>  	struct dst_entry	*sk_rx_dst;
> -	struct dst_entry	*sk_dst_cache;
> +	struct dst_entry __rcu	*sk_dst_cache;
>  	spinlock_t		sk_dst_lock;
>  	atomic_t		sk_wmem_alloc;
>  	atomic_t		sk_omem_alloc;

Thats not a complete patch.

You'll have to fix the errors it brings.
