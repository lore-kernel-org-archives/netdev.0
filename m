From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] net: cgroup: null ptr dereference in netprio cgroup
 during init
Date: Tue, 17 Jul 2012 22:50:13 -0700
Message-ID: <50064E95.7020503@intel.com>
References: <20120718003316.2979.49278.stgit@jf-dev1-dcblab> <5006188B.7060606@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, nhorman@tuxdriver.com,
	mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45789 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939Ab2GRFuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 01:50:14 -0400
In-Reply-To: <5006188B.7060606@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/17/2012 6:59 PM, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B407=E6=9C=8818=E6=97=A5 08:33, John Fastabend =E5=
=86=99=E9=81=93:
>> When the netprio cgroup is built in the kernel cgroup_init will call
>> cgrp_create which eventually calls update_netdev_tables. This is
>> being called before do_initcalls() so a null ptr dereference occurs
>> on init_net.
>>

[...]

>
>
> Thanks John.
> It's my mistake.
>
> Can we make sure init_net.count is zero here?
> I can't find some places to initialize it to zero.
>

Its defined in net_namespace.c so it's zeroed by virtue
of being global. And initialized in setup_net via
pure_initcall() always after cgroup_init() if I've done
my accounting correctly.

=2EJohn
