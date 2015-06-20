From: Jakub =?UTF-8?B?S2ljacWEc2tp?= <moorray3@wp.pl>
Subject: Re: [PATCH 00/32] Netfilter updates for net-next
Date: Sat, 20 Jun 2015 15:11:30 +0200
Message-ID: <20150620151130.74b68b6c@north>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kbuild test robot <fengguang.wu@intel.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Bernhard Thaler <bernhard.thaler@wvnet.at>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Jun 2015 23:25:57 +0200, Pablo Neira Ayuso wrote:
> Hi David,
>=20
> This a bit large (and late) patchset that contains Netfilter updates =
for
> net-next. Most relevantly br_netfilter fixes, ipset RCU support, remo=
val of
> x_tables percpu ruleset copy and rework of the nf_tables netdev suppo=
rt. More
> specifically, they are:
[...]
> ----------------------------------------------------------------
> Bernhard Thaler (7):
>       netfilter: bridge: refactor clearing BRNF_NF_BRIDGE_PREROUTING
>       netfilter: bridge: re-order br_nf_pre_routing_finish_ipv6()
>       netfilter: bridge: detect NAT66 correctly and change MAC addres=
s
>       netfilter: bridge: refactor frag_max_size
>       netfilter: bridge: rename br_parse_ip_options
>       netfilter: bridge: re-order check_hbh_len()
>       netfilter: bridge: forward IPv6 fragmented packets

Pablo, Bernhard,

this batch breaks builds with CONFIG_IPV6=3Dn.  No idea why build bot
didn't catch that.

linux/net/bridge/br_netfilter.c: In function =E2=80=98br_validate_ipv6=E2=
=80=99:
/home/kuba/Development/Linux/linux/net/bridge/br_netfilter.c:350:618: e=
rror: =E2=80=98struct netns_mib=E2=80=99 has no member named =E2=80=98i=
pv6_statistics=E2=80=99
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:350:706: error: =E2=80=98struct netns_m=
ib=E2=80=99 has no member named =E2=80=98ipv6_statistics=E2=80=99
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:350:915: error: =E2=80=98struct netns_m=
ib=E2=80=99 has no member named =E2=80=98ipv6_statistics=E2=80=99
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:350:964: error: =E2=80=98struct netns_m=
ib=E2=80=99 has no member named =E2=80=98ipv6_statistics=E2=80=99
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:350:1031: error: request for member =E2=
=80=98syncp=E2=80=99 in something not a structure or union
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:350:1044: error: request for member =E2=
=80=98mibs=E2=80=99 in something not a structure or union
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:350:1113: error: request for member =E2=
=80=98syncp=E2=80=99 in something not a structure or union
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:355:613: error: =E2=80=98struct netns_m=
ib=E2=80=99 has no member named =E2=80=98ipv6_statistics=E2=80=99
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:355:701: error: =E2=80=98struct netns_m=
ib=E2=80=99 has no member named =E2=80=98ipv6_statistics=E2=80=99
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:355:910: error: =E2=80=98struct netns_m=
ib=E2=80=99 has no member named =E2=80=98ipv6_statistics=E2=80=99
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:355:959: error: =E2=80=98struct netns_m=
ib=E2=80=99 has no member named =E2=80=98ipv6_statistics=E2=80=99
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:355:1026: error: request for member =E2=
=80=98syncp=E2=80=99 in something not a structure or union
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:355:1039: error: request for member =E2=
=80=98mibs=E2=80=99 in something not a structure or union
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:355:1103: error: request for member =E2=
=80=98syncp=E2=80=99 in something not a structure or union
    IP6_INC_STATS_BH(dev_net(dev), idev,

linux/net/bridge/br_netfilter.c:370:612: error: =E2=80=98struct netns_m=
ib=E2=80=99 has no member named =E2=80=98ipv6_statistics=E2=80=99
  IP6_INC_STATS_BH(dev_net(dev), idev, IPSTATS_MIB_INHDRERRORS);

linux/net/bridge/br_netfilter.c:370:700: error: =E2=80=98struct netns_m=
ib=E2=80=99 has no member named =E2=80=98ipv6_statistics=E2=80=99
  IP6_INC_STATS_BH(dev_net(dev), idev, IPSTATS_MIB_INHDRERRORS);

linux/net/bridge/br_netfilter.c:370:909: error: =E2=80=98struct netns_m=
ib=E2=80=99 has no member named =E2=80=98ipv6_statistics=E2=80=99
  IP6_INC_STATS_BH(dev_net(dev), idev, IPSTATS_MIB_INHDRERRORS);

linux/net/bridge/br_netfilter.c:370:958: error: =E2=80=98struct netns_m=
ib=E2=80=99 has no member named =E2=80=98ipv6_statistics=E2=80=99
  IP6_INC_STATS_BH(dev_net(dev), idev, IPSTATS_MIB_INHDRERRORS);

linux/net/bridge/br_netfilter.c:370:1025: error: request for member =E2=
=80=98syncp=E2=80=99 in something not a structure or union
  IP6_INC_STATS_BH(dev_net(dev), idev, IPSTATS_MIB_INHDRERRORS);

linux/net/bridge/br_netfilter.c:370:1038: error: request for member =E2=
=80=98mibs=E2=80=99 in something not a structure or union
  IP6_INC_STATS_BH(dev_net(dev), idev, IPSTATS_MIB_INHDRERRORS);

linux/net/bridge/br_netfilter.c:370:1103: error: request for member =E2=
=80=98syncp=E2=80=99 in something not a structure or union
  IP6_INC_STATS_BH(dev_net(dev), idev, IPSTATS_MIB_INHDRERRORS);
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
