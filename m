From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 05/19] net: Move all of the network sysctls without a namespace into init_net.
Date: Sun, 22 Apr 2012 18:50:42 -0700
Message-ID: <m1sjfvtdvx.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
	<m1k41bgv9q.fsf@fess.ebiederm.org> <4F94A494.7020006@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44546 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062Ab2DWBqo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2012 21:46:44 -0400
In-Reply-To: <4F94A494.7020006@cn.fujitsu.com> (Gao feng's message of "Mon, 23
	Apr 2012 08:38:44 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gao feng <gaofeng@cn.fujitsu.com> writes:

> =E4=BA=8E 2012=E5=B9=B404=E6=9C=8820=E6=97=A5 07:24, Eric W. Biederma=
n =E5=86=99=E9=81=93:
>>=20
>> This makes it clearer which sysctls are relative to your current net=
work
>> namespace.
>>=20
>> This makes it a little less error prone by not exposing sysctls for =
the
>> initial network namespace in other namespaces.
>>=20
>> This is the same way we handle all of our other network interfaces t=
o
>> userspace and I can't honestly remember why we didn't do this for
>> sysctls right from the start.
>>=20
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>> ---
>>  drivers/infiniband/core/ucma.c          |    4 ++--
>>  net/802/tr.c                            |    2 +-
>>  net/appletalk/sysctl_net_atalk.c        |    4 ++--
>>  net/ax25/sysctl_net_ax25.c              |    4 ++--
>>  net/bridge/br_netfilter.c               |    4 ++--
>>  net/core/neighbour.c                    |    2 +-
>>  net/core/sysctl_net_core.c              |    2 +-
>>  net/dccp/sysctl.c                       |    4 ++--
>>  net/decnet/dn_dev.c                     |    4 ++--
>>  net/decnet/sysctl_net_decnet.c          |    4 ++--
>>  net/ipv4/netfilter/ip_queue.c           |    6 +++---
>>  net/ipv4/route.c                        |    2 +-
>>  net/ipv4/sysctl_net_ipv4.c              |    4 ++--
>>  net/ipv6/netfilter/ip6_queue.c          |    6 +++---
>>  net/ipv6/netfilter/nf_conntrack_reasm.c |    4 ++--
>>  net/ipv6/sysctl_net_ipv6.c              |    2 +-
>>  net/ipx/sysctl_net_ipx.c                |    5 +++--
>>  net/irda/irsysctl.c                     |    4 ++--
>>  net/llc/sysctl_net_llc.c                |    5 +++--
>>  net/netfilter/nf_conntrack_proto.c      |    4 ++--
>
> Hi Eric
>
> actually,I'm working on making the sysctl and data of nf_conntrack pr=
oto pernet,
> and I think it's necessary,without the pernet proto timeout,we can't =
control
> the container's conntrack timeout unless we change the host's timeout=
=2E
>
> maybe somebody want the conntracks in container expired quickly.
> So I will keep on doing this job base on your patchset.
>
> what's your comment?

My quick skim of your patches suggested to me you are doing useful work=
=2E

Making sysctls that are not pernet init_net only serve two
purposes.
- Prevent mistakes by changing a sysctl you think is pernet but globall=
y
  affects the networking stack.
- Make it easy to find which sysctls need to be converted.

I suspect a lot of sysctls have not been converted simply because no on=
e
realized they had not been converted.

I hope my code cleanup did not set you back very much.  I don't believe
there were any conflicts in principle just a few places where we touche=
d
the same code.

Eric
