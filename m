From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BK PATCH] sk_dst_cache annotation
Date: Mon, 17 Jan 2005 12:49:13 -0800
Message-ID: <20050117124913.49c253b6.davem@davemloft.net>
References: <20050115.160008.04476889.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050115.160008.04476889.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 15 Jan 2005 16:00:08 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> ChangeSet@1.2335, 2005-01-15 15:47:12+09:00, yoshfuji@linux-ipv6.org
>  [NET] Always hold refcnt for dst when we use sk_dst_cache.
>  
>  Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

There is less and less point to having the socket dst cache
if we're going to take the read lock and grab an atomic
reference all the time anyways.

If the socket is locked, which most of the code paths you
are modifying do, there is no need to grab a reference
and __sk_dst_cache() is just fine.  That's how it was
mean to be used since if the socket is locked nobody
can sk_dst_reset() on us.

Let's work on this one changeset at a time, the first
one involving tcp_sync_mss() might be correct, but it
might be easier to fix this differently.  Just make PMTU
discovery behave just like ipv4 does, if there is no
socket cached route then simply return and ignore the
ICMP message.
