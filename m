From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sun, 6 Feb 2005 18:00:50 +1100
Message-ID: <20050206070050.GF16057@gondor.apana.org.au>
References: <20050206.133723.124822665.yoshfuji@linux-ipv6.org> <20050205210411.7e18b8e6.davem@davemloft.net> <20050206.143107.39728239.yoshfuji@linux-ipv6.org> <20050206.145007.34543324.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mirko.parthey@informatik.tu-chemnitz.de,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, shemminger@osdl.org
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050206.145007.34543324.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Feb 06, 2005 at 02:50:07PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> Which means in addrconf_notiry(), if the dev == &loopback_dev,
> call addrconf_ifdown for every device like this:

This should fix the reported issue.  However, I'm not sure if it's
a good idea to stop all IP traffic when lo goes down.  We don't do
that for IPv4.

Besides, we'll still need to fix the rt6i_idev GC issue since the
same bug can occur when eth0 goes down and some appliation is holding
a dst to a local address route.  It can become a dead-lock if the
said application then invokes a syscall that takes the RTNL.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
