From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6 oops on ifup in latest BK
Date: Tue, 24 Aug 2004 17:33:54 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BzVoY-00018s-00@gondolin.me.apana.org.au>
References: <20040823235123.71f18c04.davem@redhat.com>
Cc: jgarzik@pobox.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20040823235123.71f18c04.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@redhat.com> wrote:
> 
> Maybe new code should be something like:
> 
>                if (dev && dev != &loopback_dev) {

You want
		 if (dev) {
here.

>                        dev_put(dev);
>                        in6_dev_put(idev);
>                }
>                dev = &loopback_dev;
>                dev_hold(dev);
>                idev = in6_dev_get(dev);
>                if (!idev) {
>                        err = -ENODEV;
>                        goto out;
>                }
> 
> What do you think?

Yes this would work.  But I think Yoshifuji-san is trying to avoid the
unnecessary put/get in the case where dev is already loopback_dev.
So something like this might work:

		if (dev != &loopback_dev) {
			if (dev) {
				dev_put(dev);
				in6_dev_put(idev);
			}
			...
		}
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
