From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] bql: Byte queue limits
Date: Tue, 26 Apr 2011 07:38:33 +0200
Message-ID: <1303796313.2747.190.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1104252128290.5895@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41578 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab1DZFij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 01:38:39 -0400
Received: by wya21 with SMTP id 21so175041wya.19
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 22:38:38 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1104252128290.5895@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 avril 2011 =C3=A0 21:38 -0700, Tom Herbert a =C3=A9crit :
> Networking stack support for byte queue limits, uses dynamic queue
> limits library.  Byte queue limits are maintained per transmit queue,
> and a bql structure has been added to netdev_queue structure for this
> purpose.
>=20
> Configuration of bql is in the tx-<n> sysfs directory for the queue
> under the byte_queue_limits directory.  Configuration includes:
> limit_min, bql minimum limit
> limit_max, bql maximum limit
> hold_time, bql slack hold time
>=20
> Also under the directory are:
> limit, current byte limit
> inflight, current number of bytes on the queue
>=20

Wow... magical values and very limited advices how to tune them.

Tom, this reminds me you were supposed to provide Documentation/files t=
o
describe RPS, RFS, XPS ...

We receive many questions about these features...

> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/netdevice.h |   46 +++++++++++++++-
>  net/core/net-sysfs.c      |  137 +++++++++++++++++++++++++++++++++++=
++++++++--
>  2 files changed, 177 insertions(+), 6 deletions(-)
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index cb8178a..0a76b88 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -44,6 +44,7 @@
>  #include <linux/rculist.h>
>  #include <linux/dmaengine.h>
>  #include <linux/workqueue.h>
> +#include <linux/dynamic_queue_limits.h>
> =20
>  #include <linux/ethtool.h>
>  #include <net/net_namespace.h>
> @@ -556,8 +557,10 @@ struct netdev_queue {
>  	struct Qdisc		*qdisc;
>  	unsigned long		state;
>  	struct Qdisc		*qdisc_sleeping;
> -#ifdef CONFIG_RPS
> +#ifdef CONFIG_XPS
>  	struct kobject		kobj;
> +	bool			do_bql;
> +	struct dql		dql;
>  #endif

I have no idea why you use CONFIG_XPS for BQL (how BQL is it related to
SMP ???), and why kobj is now guarded by CONFIG_XPS instead of
CONFIG_RPS.



