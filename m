From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: [PATCH net] ipv6: Fix may be used uninitialized warning in
 rt6_check
Date: Fri, 25 Aug 2017 11:02:06 +0200
Message-ID: <20170825110206.36e4a7a7@elisabeth>
References: <20170825070542.GV31224@secunet.com>
        <20170825075217.GW31224@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>,
        Eric Dumazet <edumazet@google.com>,
        "Martin KaFai Lau" <kafai@fb.com>, <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37152 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755059AbdHYJCN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 05:02:13 -0400
In-Reply-To: <20170825075217.GW31224@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Aug 2017 09:52:17 +0200
Steffen Klassert <steffen.klassert@secunet.com> wrote:

> On Fri, Aug 25, 2017 at 09:05:42AM +0200, Steffen Klassert wrote:
> > rt_cookie might be used uninitialized, fix this by
> > initializing it.
> > 
> > Fixes: c5cff8561d2d ("ipv6: add rcu grace period before freeing fib6_node")
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > ---
> >  net/ipv6/route.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index a9d3564..48c8c92 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -1289,7 +1289,7 @@ static void rt6_dst_from_metrics_check(struct rt6_info *rt)
> >  
> >  static struct dst_entry *rt6_check(struct rt6_info *rt, u32 cookie)
> >  {
> > -	u32 rt_cookie;
> > +	u32 rt_cookie = 0;
> >  
> >  	if (!rt6_get_cookie_safe(rt, &rt_cookie) || rt_cookie != cookie)
> >  		return NULL;  
> 
> The compiler warning seems to be a false positive, as
> rt_cookie != cookie is only checked if rt6_get_cookie_safe
> returns true in which case rt_cookie is initialized.
> 
> Please disregard this patch.

...or not? I was thinking of sending a similar patch with
uninitialized_var(rt_cookie), but it seems we have similar cases
where we just initialize to zero instead.

I wonder which approach is considered the most acceptable nowadays. I
would be in favour of uninitialized_var() as it doesn't change the
binary output, but https://lwn.net/Articles/529954/ also contains some
valid criticism. Ideas?
