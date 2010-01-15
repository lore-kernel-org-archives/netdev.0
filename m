From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: RE: [PATCH] net/ipv4/fib_semantics.c: quiet sparse "shadows" noise
Date: Fri, 15 Jan 2010 11:57:41 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE190902089F54@mi8nycmail19.Mi8.com>
References: <201001141652.42757.hartleys@visionengravers.com> <20100115.011730.263631545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og103.obsmtp.com ([64.18.1.185]:44588 "HELO
	exprod6og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751111Ab0AOQ5p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 11:57:45 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20100115.011730.263631545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, January 15, 2010 2:18 AM, David Miller wrote:
> From: H Hartley Sweeten <hartleys@visionengravers.com>
> Date: Thu, 14 Jan 2010 16:52:41 -0700
>
>> net/ipv4/fib_semantics.c: quiet sparse "shadows" noise
>> 
>> If CONFIG_IP_ROUTE_MULTIPATH is defined the symbol 'nh' is
>> declared twice in the function fib_sync_down_dev. First as the
>> loop variable used to iterate the hlist. Then again due to the
>> change_nexthops macro. This produces a sparse warning and
>> makes the code harder to understand.
>> 
>> Fix the issue by renaming the first symbol.
>> 
>> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
>
> I think it's easier to fix this by using a less simple name
> in change_nexthops(), so I'll deal with this using the following
> patch.

OK. The patch is larger but it's much clearer this way.

> Thanks for reporting this:
>
> ipv4: Use less conflicting local var name in change_nexthops() loop macro.
>
> As noticed by H Hartley Sweeten, since change_nexthops() uses 'nh'
> as it's iterator variable, it can conflict with other existing
> local vars.
>
> Use "nexthop_nh" to avoid the conflict and make it easier to figure
> out where this magic variable comes from.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Tested-by: H Hartley Sweeten <hsweeten@visionengravers.com>
