From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Don't assign a same IPv6 address on a same
 interface (is Re: IPv6 duplicate address bugfix)
Date: Mon, 31 Mar 2003 03:35:24 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030331.033524.114862210.yoshfuji@linux-ipv6.org>
References: <20030330.220829.129728506.yoshfuji@linux-ipv6.org>
	<20030330.235809.70243437.yoshfuji@linux-ipv6.org>
	<20030330163656.GA18645@ferrara.linux.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pioppo@ferrara.linux.it
In-Reply-To: <20030330163656.GA18645@ferrara.linux.it>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030330163656.GA18645@ferrara.linux.it> (at Sun, 30 Mar 2003 18:36:56 +0200), Simone Piunno <pioppo@ferrara.linux.it> says:

> Because everywhere else in the file {read,write}_lock_bh() is used 
> instead of {read,write}_lock(), so I'm assuming that _bh is required 
> but I really don't know why.

maybe.

>  - locking inside ipv6_add_addr() is simpler and more linear but
>    semantically wrong because you're unable to tell the user why his 
>    "ip addr add" failed.  E.g. you answer ENOBUFS instead of EEXIST.

We don't want to create duplicate address in any case.
ipv6_add_addr() IS right place.
And, we can return error code by using IS_ERR() etc.
I'll fix this.


>  - your ipv6_chk_same_addr() does a useless check for (dev != NULL)
> 
>    > +static
>    > +int ipv6_chk_same_addr(const struct in6_addr *addr, struct net_device *dev)
>    > +{
>    > +	struct inet6_ifaddr * ifp;
>    > +	u8 hash = ipv6_addr_hash(addr);
>    > +
>    > +	read_lock_bh(&addrconf_hash_lock);
>    > +	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
>    > +		if (ipv6_addr_cmp(&ifp->addr, addr) == 0) {
>    > +			if (dev != NULL && ifp->idev->dev == dev)
>    >  				break;
>    >  		}
> 
>    your never "break" if dev == NULL, so you could return 0 before
>    even acquiring the lock.

It is not a problem because dev is always non-NULL.
However, it should be dev == NULL || ifp->idev->dev == dev.
Thanks.
(I don't understand what you mean by "you could return 0
before even acquiring the lock.")

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
