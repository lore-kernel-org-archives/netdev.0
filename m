From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v3 2/2] ipv6: fix ECMP route replacement
Date: Wed, 20 May 2015 10:56:31 +0200
Message-ID: <555C4C3F.8030003@6wind.com>
References: <cover.1431974706.git.mkubecek@suse.cz> <239760fdec3e503029fae3e5bb9d4eb3c4c33c20.1431974706.git.mkubecek@suse.cz>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	roopa <roopa@cumulusnetworks.com>
To: Michal Kubecek <mkubecek@suse.cz>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <239760fdec3e503029fae3e5bb9d4eb3c4c33c20.1431974706.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 18/05/2015 20:54, Michal Kubecek a =C3=A9crit :
> When replacing an IPv6 multipath route with "ip route replace", i.e.
> NLM_F_CREATE | NLM_F_REPLACE, fib6_add_rt2node() replaces only first
> matching route without fixing its siblings, resulting in corrupted
> siblings linked list; removing one of the siblings can then end in an
> infinite loop.
>
> IPv6 ECMP implementation is a bit different from IPv4 so that route
> replacement cannot work in exactly the same way. This should be a
> reasonable approximation:
>
> 1. If the new route is ECMP-able and there is a matching ECMP-able on=
e
> already, replace it and all its siblings (if any).
>
> 2. If the new route is ECMP-able and no matching ECMP-able route exis=
ts,
> replace first matching non-ECMP-able (if any) or just add the new one=
=2E
>
> 3. If the new route is not ECMP-able, replace first matching
> non-ECMP-able route (if any) or add the new route.
>
> We also need to remove the NLM_F_REPLACE flag after replacing old
> route(s) by first nexthop of an ECMP route so that each subsequent
> nexthop does not replace previous one.
>
> Fixes: 51ebd3181572 ("ipv6: add support of equal cost multipath (ECMP=
)")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
LGTM.
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
