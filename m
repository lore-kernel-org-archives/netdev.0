From: Dan Streetman <dan.streetman@canonical.com>
Subject: Re: [PATCHv2] xfrm: dst_entries_init() per-net dst_ops
Date: Thu, 29 Oct 2015 09:46:31 -0400
Message-ID: <CAOZ2QJMFBO16hFbtzP1PsGNgCC0uFEWM0pLp8zLPQnXV6H1BtQ@mail.gmail.com>
References: <1446118162-5385-1-git-send-email-dan.streetman@canonical.com> <201510291946.jwFKT9p2%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dan Streetman <ddstreet@ieee.org>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37644 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965131AbbJ2NrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 09:47:12 -0400
Received: by igbhv6 with SMTP id hv6so30855958igb.0
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 06:47:11 -0700 (PDT)
In-Reply-To: <201510291946.jwFKT9p2%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2015 at 7:57 AM, kbuild test robot <lkp@intel.com> wrote:
> Hi Dan,
>
> [auto build test WARNING on ipsec/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]
>
> url:    https://github.com/0day-ci/linux/commits/Dan-Streetman/xfrm-dst_entries_init-per-net-dst_ops/20151029-193245
> config: x86_64-randconfig-x019-201543 (attached as .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All warnings (new ones prefixed by >>):
>
>    net/xfrm/xfrm_policy.c: In function 'xfrm_policy_register_afinfo':
>>> net/xfrm/xfrm_policy.c:2810:14: warning: unused variable 'net' [-Wunused-variable]
>      struct net *net;
>                  ^

well, i should have caught that one.  resending patch.

thnx!

>
> vim +/net +2810 net/xfrm/xfrm_policy.c
>
> ebb762f27 Steffen Klassert 2011-11-23  2794  static unsigned int xfrm_mtu(const struct dst_entry *dst)
> d33e45533 David S. Miller  2010-12-14  2795  {
> 618f9bc74 Steffen Klassert 2011-11-23  2796     unsigned int mtu = dst_metric_raw(dst, RTAX_MTU);
> 618f9bc74 Steffen Klassert 2011-11-23  2797
> 618f9bc74 Steffen Klassert 2011-11-23  2798     return mtu ? : dst_mtu(dst->path);
> d33e45533 David S. Miller  2010-12-14  2799  }
> d33e45533 David S. Miller  2010-12-14  2800
> f894cbf84 David S. Miller  2012-07-02  2801  static struct neighbour *xfrm_neigh_lookup(const struct dst_entry *dst,
> f894cbf84 David S. Miller  2012-07-02  2802                                        struct sk_buff *skb,
> f894cbf84 David S. Miller  2012-07-02  2803                                        const void *daddr)
> d3aaeb38c David S. Miller  2011-07-18  2804  {
> f894cbf84 David S. Miller  2012-07-02  2805     return dst->path->ops->neigh_lookup(dst, skb, daddr);
> d3aaeb38c David S. Miller  2011-07-18  2806  }
> d3aaeb38c David S. Miller  2011-07-18  2807
> ^1da177e4 Linus Torvalds   2005-04-16  2808  int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo)
> ^1da177e4 Linus Torvalds   2005-04-16  2809  {
> d7c7544c3 Alexey Dobriyan  2010-01-24 @2810     struct net *net;
> ^1da177e4 Linus Torvalds   2005-04-16  2811     int err = 0;
> ^1da177e4 Linus Torvalds   2005-04-16  2812     if (unlikely(afinfo == NULL))
> ^1da177e4 Linus Torvalds   2005-04-16  2813             return -EINVAL;
> ^1da177e4 Linus Torvalds   2005-04-16  2814     if (unlikely(afinfo->family >= NPROTO))
> ^1da177e4 Linus Torvalds   2005-04-16  2815             return -EAFNOSUPPORT;
> ef8531b64 Eric Dumazet     2012-08-19  2816     spin_lock(&xfrm_policy_afinfo_lock);
> ^1da177e4 Linus Torvalds   2005-04-16  2817     if (unlikely(xfrm_policy_afinfo[afinfo->family] != NULL))
> f31e8d4f7 Li RongQing      2015-04-23  2818             err = -EEXIST;
>
> :::::: The code at line 2810 was first introduced by commit
> :::::: d7c7544c3d5f59033d1bf3236bc7b289f5f26b75 netns xfrm: deal with dst entries in netns
>
> :::::: TO: Alexey Dobriyan <adobriyan@gmail.com>
> :::::: CC: David S. Miller <davem@davemloft.net>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
