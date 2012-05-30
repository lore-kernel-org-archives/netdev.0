From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/4] inet: add counter to inet_bind_hashbucket
Date: Wed, 30 May 2012 10:00:21 +0200
Message-ID: <1338364821.2760.99.camel@edumazet-glaptop>
References: <1338363410-6562-1-git-send-email-alex.mihai.c@gmail.com>
	 <1338363410-6562-2-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>,
	Lucian Grijincu <lucian.grijincu@gmail.com>
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39400 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756198Ab2E3IA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 04:00:26 -0400
Received: by bkcji2 with SMTP id ji2so3830462bkc.19
        for <netdev@vger.kernel.org>; Wed, 30 May 2012 01:00:25 -0700 (PDT)
In-Reply-To: <1338363410-6562-2-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 10:36 +0300, Alexandru Copot wrote:
> The counter will be used by the upcoming INET lookup algorithm to
> choose the shortest chain after secondary hash is added.
> 
> Signed-off-by: Alexandru Copot <alex.mihai.c@gmail.com>
> Cc: Daniel Baluta <dbaluta@ixiacom.com>
> Cc: Lucian Grijincu <lucian.grijincu@gmail.com>
> ---
>  include/net/inet_hashtables.h    |    4 +++-
>  include/net/inet_timewait_sock.h |    4 +++-
>  net/dccp/proto.c                 |    1 +
>  net/ipv4/inet_hashtables.c       |    9 ++++++---
>  net/ipv4/inet_timewait_sock.c    |    7 ++++---
>  net/ipv4/tcp.c                   |    1 +
>  6 files changed, 18 insertions(+), 8 deletions(-)
> 
> diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
> index 808fc5f..8c6addc 100644
> --- a/include/net/inet_hashtables.h
> +++ b/include/net/inet_hashtables.h
> @@ -98,6 +98,7 @@ static inline struct net *ib_net(struct inet_bind_bucket *ib)
>  struct inet_bind_hashbucket {
>  	spinlock_t		lock;
>  	struct hlist_head	chain;
> +	unsigned int		count;
>  };
>  

Are you still using 32bit kernel ?

better use :

struct inet_bind_hashbucket {
	spinlock_t		lock;
	unsigned int		count;
 	struct hlist_head	chain;
};
