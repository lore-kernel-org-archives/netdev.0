From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sun, 06 Feb 2005 14:31:07 +0900 (JST)
Message-ID: <20050206.143107.39728239.yoshfuji@linux-ipv6.org>
References: <20050205201044.1b95f4e8.davem@davemloft.net>
	<20050206.133723.124822665.yoshfuji@linux-ipv6.org>
	<20050205210411.7e18b8e6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mirko.parthey@informatik.tu-chemnitz.de,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, shemminger@osdl.org,
        yoshfuji@linux-ipv6.org
To: davem@davemloft.net
In-Reply-To: <20050205210411.7e18b8e6.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050205210411.7e18b8e6.davem@davemloft.net> (at Sat, 5 Feb 2005 21:04:11 -0800), "David S. Miller" <davem@davemloft.net> says:

> On Sun, 06 Feb 2005 13:37:23 +0900 (JST)
> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:
> 
> > How about making dst->ops->dev_check() like this:
> > 
> > static int inline dst_dev_check(struct dst_entry *dst, struct net_device *dev)
> > {
> > 	if (dst->ops->dev_check)
> > 		return dst->ops->dev_check(dst, dev)
> > 	else
> > 		return dst->dev == dev;
> > }
> 
> Oh I see.  That would work, and it seems the simplest, and
> lowest risk fix for this problem.

Well...

Here, lo is going down.
rt->rt6i_dev = lo and rt->rt6i_idev = ethX.
I think we already see dst->dev == dev (==lo)  now.
So, I doubt that fix the problem.

The source of problem is entry (*) which still on routing entry,
not on gc list. And, the owner of entry is not routing table but
unicast/anycast address structure(s).
We need to "kill" active address on the other interfaces.

*: rt->rt6i_dev = lo and rt->rt6i_idev = ethX


BTW, I wish we could shut down eth0 during lo is pending...

--yoshfuji
