From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3 XFRM]: Fix invalid key for lookup of cached bundles
Date: Sun, 06 Mar 2005 11:54:07 +0100
Message-ID: <422AE14F.6000805@trash.net>
References: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1D7t0w-0008Qa-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>@@ -97,6 +104,7 @@
>> 		err = xfrm_dst_lookup((struct xfrm_dst**)&rt, &fl_tunnel, AF_INET);
>> 		if (err)
>> 			goto error;
>>+		rt->u.dst.flags |= DST_XFRM_TUNNEL;
> 
> 
> This line doesn't look right.  rt is an entry in the IPv4 routing
> cache, right? If so why should its flags change when some bundle is
> created?
> 
> After all, it could also be used at the bottom of a transport mode bundle.

Oops, that is correct of course. I wanted to kill the ugly int
*is_tunnel argument to xfrm_bundle_ok() in my last patch, but
I need to look for a different way.

> Besides, I think IPv4 routing cache entry will never show up at the top of
> a bundle anyway which means that this flags value will never be read in
> the find_bundle function.

At least that part was correct, __xfrm4_find_bundle() uses
dst->path->flags in my patch.

Thanks,
Patrick
