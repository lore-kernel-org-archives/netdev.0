From: jamal <hadi@cyberus.ca>
Subject: Re: [RTNETLINK] Provide real oif
Date: 03 Dec 2003 08:51:03 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1070459463.1036.179.camel@jzny.localdomain>
References: <E1ARULX-0000Ny-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1ARULX-0000Ny-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Wed, 2003-12-03 at 05:35, Herbert Xu wrote:

> They both have an RTA_OIF of eth0.  But RTA_OIF != rt->fl.oif.  In fact,
> RTA_OIF is the value of rt->u.dst.dev.

(to be precise: rt->u.dst.dev->ifindex)
Ok, now i understand what you are saying. In one case you taught the
kernel the oif to use in the other you let it select the default.
i.e:
ip r g x.x.x.x dev eth0
and to select the default: 
ip r g x.x.x.x
ip r l c should show them to be exact.

In your case your selection and the default just happen
to be the same device. 

I am wondering if they should have been the same resolved 
cache entry to begin with. i.e the fl->oif should not have 
been 0 rather the ifindex of eth0.
Even in the case of multipath routing, you have to wait for 
the cache to expire before selecting the next one in the slow 
path; so fl->oif of zero may not be a very useful artifact. 

cheers,
jamal
