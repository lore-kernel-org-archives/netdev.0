From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RESEND 8/8] af_unix: charge buffers to kmemcg
Date: Tue, 24 May 2016 06:02:06 -0700
Message-ID: <1464094926.5939.48.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
	 <fcfe6cae27a59fbc5e40145664b3cf085a560c68.1464079538.git.vdavydov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller"
	 <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko
	 <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <fcfe6cae27a59fbc5e40145664b3cf085a560c68.1464079538.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-05-24 at 11:49 +0300, Vladimir Davydov wrote:
> Unix sockets can consume a significant amount of system memory, hence
> they should be accounted to kmemcg.
> 
> Since unix socket buffers are always allocated from process context,
> all we need to do to charge them to kmemcg is set __GFP_ACCOUNT in
> sock->sk_allocation mask.

I have two questions : 

1) What happens when a buffer, allocated from socket <A> lands in a
different socket <B>, maybe owned by another user/process.

Who owns it now, in term of kmemcg accounting ?

2) Has performance impact been evaluated ?

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
