From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] netem: Introduce skb_orphan_partial() helper
Date: Wed, 31 Jul 2013 03:21:33 +0000 (UTC)
Message-ID: <kt9vrt$occ$1@ger.gmane.org>
References: <1375232108.10515.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:57412 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752696Ab3GaDVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jul 2013 23:21:54 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1V4Mz2-0004Ur-7c
	for netdev@vger.kernel.org; Wed, 31 Jul 2013 05:21:52 +0200
Received: from 222.221.58.17 ([222.221.58.17])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 05:21:52 +0200
Received: from xiyou.wangcong by 222.221.58.17 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 05:21:52 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Jul 2013 at 00:55 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> diff --git a/include/net/sock.h b/include/net/sock.h
> index b9f2b09..53d4714 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1520,6 +1520,7 @@ extern struct sk_buff		*sock_rmalloc(struct sock *sk,
>  					      unsigned long size, int force,
>  					      gfp_t priority);
>  extern void			sock_wfree(struct sk_buff *skb);
> +extern void			skb_orphan_partial(struct sk_buff *skb);
>  extern void			sock_rfree(struct sk_buff *skb);
>  extern void			sock_edemux(struct sk_buff *skb);
>  
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 85e8de1..a753d97 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1576,6 +1576,25 @@ void sock_wfree(struct sk_buff *skb)
>  }
>  EXPORT_SYMBOL(sock_wfree);
>  
> +void skb_orphan_partial(struct sk_buff *skb)

I think net/core/skbuff.c is a better place to put this (or skbuff.h
if it can be inlined).
