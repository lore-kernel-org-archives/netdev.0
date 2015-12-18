From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 03/14] ipv4, ipv6: use list_for_each_entry*
Date: Fri, 18 Dec 2015 17:59:18 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1512181758150.2499@hadrien>
References: <201512190031.S65NXNNd%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kbuild-all@01.org
To: Geliang Tang <geliangtang@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201512190031.S65NXNNd%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't think this code can work.  list_for_each_entry uses answer to get
from one element to the next.

julia

On Sat, 19 Dec 2015, kbuild test robot wrote:

> CC: kbuild-all@01.org
> In-Reply-To: <0167bba2ecf8c4fcb6b0b3135a4e957309986498.1450451516.git.geliangtang@163.com>
> TO: Geliang Tang <geliangtang@163.com>
> CC: "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, James Morris <jmorris@namei.org>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Patrick McHardy <kaber@trash.net>
> CC: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
>
> Hi Geliang,
>
> [auto build test WARNING on net/master]
> [also build test WARNING on v4.4-rc5 next-20151218]
>
> url:    https://github.com/0day-ci/linux/commits/Geliang-Tang/Bluetooth-use-list_for_each_entry/20151218-234306
> :::::: branch date: 69 minutes ago
> :::::: commit date: 69 minutes ago
>
> >> net/ipv6/af_inet6.c:589:1-20: iterator with update on line 597
>
> git remote add linux-review https://github.com/0day-ci/linux
> git remote update linux-review
> git checkout c5e8d791cacac62eeec48e00a1a14a6a350670f4
> vim +589 net/ipv6/af_inet6.c
>
> ^1da177e Linus Torvalds 2005-04-16  583  		goto out_illegal;
> ^1da177e Linus Torvalds 2005-04-16  584
> ^1da177e Linus Torvalds 2005-04-16  585  	/* If we are trying to override a permanent protocol, bail. */
> ^1da177e Linus Torvalds 2005-04-16  586  	answer = NULL;
> 87c3efbf Daniel Lezcano 2007-12-11  587  	ret = -EPERM;
> ^1da177e Linus Torvalds 2005-04-16  588  	last_perm = &inetsw6[p->type];
> c5e8d791 Geliang Tang   2015-12-18 @589  	list_for_each_entry(answer, &inetsw6[p->type], list) {
> ^1da177e Linus Torvalds 2005-04-16  590  		/* Check only the non-wild match. */
> ^1da177e Linus Torvalds 2005-04-16  591  		if (INET_PROTOSW_PERMANENT & answer->flags) {
> ^1da177e Linus Torvalds 2005-04-16  592  			if (protocol == answer->protocol)
> ^1da177e Linus Torvalds 2005-04-16  593  				break;
> c5e8d791 Geliang Tang   2015-12-18  594  			last_perm = &answer->list;
> ^1da177e Linus Torvalds 2005-04-16  595  		}
> ^1da177e Linus Torvalds 2005-04-16  596
> ^1da177e Linus Torvalds 2005-04-16 @597  		answer = NULL;
> ^1da177e Linus Torvalds 2005-04-16  598  	}
> ^1da177e Linus Torvalds 2005-04-16  599  	if (answer)
> ^1da177e Linus Torvalds 2005-04-16  600  		goto out_permanent;
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>
