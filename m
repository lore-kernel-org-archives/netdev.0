From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Sat, 11 Jun 2011 08:54:09 +0800
Message-ID: <BANLkTikU_ug=zUdfOZAX6eJ+BD9ZZvDrJA@mail.gmail.com>
References: <1307600810.3980.85.camel@edumazet-laptop> <1307664235.17300.44.camel@schen9-DESK>
 <20110609.204330.2090335955971650557.davem@davemloft.net> <1307745190.17300.85.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, andi@firstfloor.org
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47040 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758378Ab1FKAya convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 20:54:30 -0400
Received: by bwz15 with SMTP id 15so2585868bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 17:54:29 -0700 (PDT)
In-Reply-To: <1307745190.17300.85.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 11, 2011 at 6:33 AM, Tim Chen <tim.c.chen@linux.intel.com> =
wrote:
>
> You're right. =A0By adding the TCP connection, inet peer shows up now=
 in
> my profile of the patched kernel with Eric's two patches.
>
> Eric's patches produced much better cpu utilization.
> The addr_compare (used to consume 10% cpu) and atomic_dec_and_lock (u=
sed
> to consume 20.5% cpu) in inet_putpeer is eliminated and inet_putpeer
> uses only 10% cpu now. =A0Though inet_getpeer and inet_putpeer still
> consumes significant cpu compared to the other test case when peer is
> not present.
>
> Tim
>
> Profile with Eric's two patches and peer forced to be present with TC=
P
> added looks like this:
>
> - =A0 =A0 19.38% =A0 =A0 memcached =A0[kernel.kallsyms] =A0 =A0 =A0 =A0=
 =A0 =A0 [k] inet_getpeer
> =A0 - inet_getpeer
> =A0 =A0 =A0+ 99.97% inet_getpeer_v4
> - =A0 =A0 11.49% =A0 =A0 memcached =A0[kernel.kallsyms] =A0 =A0 =A0 =A0=
 =A0 =A0 [k] inet_putpeer
> =A0 - inet_putpeer
> =A0 =A0 =A0- 99.96% ipv4_dst_destroy
> =A0 =A0 =A0 =A0 =A0 dst_destroy
> =A0 =A0 =A0 =A0 + dst_release
> - =A0 =A0 =A05.71% =A0 =A0 memcached =A0[kernel.kallsyms] =A0 =A0 =A0=
 =A0 =A0 =A0 [k] rt_set_nexthop.clone.30
> =A0 - rt_set_nexthop.clone.30
> =A0 =A0 =A0+ 99.89% __ip_route_output_key
> - =A0 =A0 =A05.60% =A0 =A0 memcached =A0[kernel.kallsyms] =A0 =A0 =A0=
 =A0 =A0 =A0 [k] atomic_add_unless.clone.34
> =A0 - atomic_add_unless.clone.34
> =A0 =A0 =A0+ 99.94% neigh_lookup
> + =A0 =A0 =A03.02% =A0 =A0 memcached =A0[kernel.kallsyms] =A0 =A0 =A0=
 =A0 =A0 =A0 [k] do_raw_spin_lock
> + =A0 =A0 =A02.87% =A0 =A0 memcached =A0[kernel.kallsyms] =A0 =A0 =A0=
 =A0 =A0 =A0 [k] atomic_dec_and_test
> + =A0 =A0 =A01.45% =A0 =A0 memcached =A0[kernel.kallsyms] =A0 =A0 =A0=
 =A0 =A0 =A0 [k] atomic_add
> + =A0 =A0 =A01.04% =A0 =A0 memcached =A0[kernel.kallsyms] =A0 =A0 =A0=
 =A0 =A0 =A0 [k] _raw_spin_lock_irqsave
> + =A0 =A0 =A01.03% =A0 =A0 memcached =A0[kernel.kallsyms] =A0 =A0 =A0=
 =A0 =A0 =A0 [k] bit_spin_lock.clone.41
>
>

Did you disable routing cache when profiling? If so, enable it and try =
again.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
