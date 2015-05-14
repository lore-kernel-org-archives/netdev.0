From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v2 1/2] ipv6: do not delete previously existing ECMP
 routes if add fails
Date: Thu, 14 May 2015 20:54:05 +0200
Message-ID: <5554EF4D.9030803@6wind.com>
References: <cover.1431546602.git.mkubecek@suse.cz> <bb3d4b3ef28339bbf863a42e569bbdc1078565ee.1431546602.git.mkubecek@suse.cz>
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
In-Reply-To: <bb3d4b3ef28339bbf863a42e569bbdc1078565ee.1431546602.git.mkubecek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 13/05/2015 21:59, Michal Kubecek a =C3=A9crit :
> If adding a nexthop of an IPv6 multipath route fails, comment in
> ip6_route_multipath() says we are going to delete all nexthops alread=
y
> added. However, current implementation deletes even the routes it
> hasn't even tried to add yet. For example, running
>
>    ip route add 1234:5678::/64 \
>        nexthop via fe80::aa dev dummy1 \
>        nexthop via fe80::bb dev dummy1 \
>        nexthop via fe80::cc dev dummy1
>
> twice results in removing all routes first command added.
>
> Limit the second (delete) run to nexthops that succeeded in the first
> (add) run.
>
> Fixes: 51ebd3181572 ("ipv6: add support of equal cost multipath (ECMP=
)")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
