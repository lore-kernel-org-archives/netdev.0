From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [BK PATCH] sk_dst_cache annotation
Date: Tue, 18 Jan 2005 11:40:34 +0900 (JST)
Message-ID: <20050118.114034.89476074.yoshfuji@linux-ipv6.org>
References: <20050115.160008.04476889.yoshfuji@linux-ipv6.org>
	<20050117124913.49c253b6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20050117124913.49c253b6.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050117124913.49c253b6.davem@davemloft.net> (at Mon, 17 Jan 2005 12:49:13 -0800), "David S. Miller" <davem@davemloft.net> says:

> On Sat, 15 Jan 2005 16:00:08 +0900 (JST)
> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:
> 
> > ChangeSet@1.2335, 2005-01-15 15:47:12+09:00, yoshfuji@linux-ipv6.org
> >  [NET] Always hold refcnt for dst when we use sk_dst_cache.
> >  
> >  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> 
> There is less and less point to having the socket dst cache
> if we're going to take the read lock and grab an atomic
> reference all the time anyways.
> 
> If the socket is locked, which most of the code paths you
> are modifying do, there is no need to grab a reference
> and __sk_dst_cache() is just fine.  That's how it was
> mean to be used since if the socket is locked nobody
> can sk_dst_reset() on us.

I'll see them again.

Let me clarify:
  if all the code paths (for each socket type) lock socket,
  we don't need sk_dst_lock at all (for that socket type).
  otherwise, we have races; we need sk_dst_lock (for that socket type).

Am I corrent?

--yoshfuji
