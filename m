From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [RFC PATCH] net: cgroup: null ptr dereference in netprio cgroup
 during init
Date: Wed, 18 Jul 2012 15:58:25 +0800
Message-ID: <50066CA1.1060305@cn.fujitsu.com>
References: <20120718003316.2979.49278.stgit@jf-dev1-dcblab> <5006188B.7060606@cn.fujitsu.com> <50064E95.7020503@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, nhorman@tuxdriver.com,
	mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:38200 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750999Ab2GRH6J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 03:58:09 -0400
In-Reply-To: <50064E95.7020503@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8818=E6=97=A5 13:50, John Fastabend =E5=
=86=99=E9=81=93:
> On 7/17/2012 6:59 PM, Gao feng wrote:
>> =E4=BA=8E 2012=E5=B9=B407=E6=9C=8818=E6=97=A5 08:33, John Fastabend =
=E5=86=99=E9=81=93:
>>> When the netprio cgroup is built in the kernel cgroup_init will cal=
l
>>> cgrp_create which eventually calls update_netdev_tables. This is
>>> being called before do_initcalls() so a null ptr dereference occurs
>>> on init_net.
>>>
>=20
> [...]
>=20
>>
>>
>> Thanks John.
>> It's my mistake.
>>
>> Can we make sure init_net.count is zero here?
>> I can't find some places to initialize it to zero.
>>
>=20
> Its defined in net_namespace.c so it's zeroed by virtue
> of being global. And initialized in setup_net via
> pure_initcall() always after cgroup_init() if I've done
> my accounting correctly.

This looks fine to me.
Thanks John.
