From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sun, 06 Feb 2005 13:37:23 +0900 (JST)
Message-ID: <20050206.133723.124822665.yoshfuji@linux-ipv6.org>
References: <20050204221344.247548cb.davem@davemloft.net>
	<20050205064643.GA29758@gondor.apana.org.au>
	<20050205201044.1b95f4e8.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mirko.parthey@informatik.tu-chemnitz.de,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, shemminger@osdl.org,
        yoshfuji@linux-ipv6.org
To: davem@davemloft.net
In-Reply-To: <20050205201044.1b95f4e8.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050205201044.1b95f4e8.davem@davemloft.net> (at Sat, 5 Feb 2005 20:10:44 -0800), "David S. Miller" <davem@davemloft.net> says:

> > Alternatively we can
> > remove the dst->dev == dev check in dst_dev_event and dst_ifdown
> > and move that test down to the individual ifdown functions.
> 
> I think there is a hole in this idea.... maybe.
> 
> If the idea is to scan dst_garbage_list down in ipv6 specific code,
> you can't do that since 'dst' objects from every pool in the kernel
> get put onto the dst_garbage_list.   It is generic.

How about making dst->ops->dev_check() like this:

static int inline dst_dev_check(struct dst_entry *dst, struct net_device *dev)
{
	if (dst->ops->dev_check)
		return dst->ops->dev_check(dst, dev)
	else
		return dst->dev == dev;
}

--yoshfuji
