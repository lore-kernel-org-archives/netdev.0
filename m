From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v4 2/5] can: add rtnetlink support
Date: Sun, 01 May 2011 19:16:54 +0200
Message-ID: <4DBD9586.7080908@hartkopp.net>
References: <20110427085330.GA757@kurt.e-circ.dyndns.org> <20110427085705.GC757@kurt.e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:30521 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776Ab1EARQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2011 13:16:45 -0400
In-Reply-To: <20110427085705.GC757@kurt.e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27.04.2011 10:57, Kurt Van Dijck wrote:
> This patch adds rtnetlink support for AF_CAN. This support is really
> a multiplexer towards the different CAN protocols.

Hello Kurt,

i applied all your patches for the can-utils and the network layer stuff to
the BerliOS SVN in socketcan/branches/j1939 for testing.

Besides some minor adaptions to support the SVN i left out some infrastructure
changes you made in patch 2/5 to constify this ...

> -static struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;
> +static const struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;

and this ...

> -static struct can_proto *can_try_module_get(int protocol)
> +static const struct can_proto *can_try_module_get(int protocol)

(..)

> +static inline void can_put_proto(const struct can_proto *cp)
> +{
> +	module_put(cp->prot->owner);
> +}

These infrastructure changes did not really belong to the rtnetlink support.

The can-j1939.ko builds properly in the SVN against 2.6.39-rc5 and the
net-next-2.6 tree - and e.g. against a debian wheezy kernel:

make KERNELDIR=/usr/src/linux-headers-2.6.38-2-686-bigmem

As it is pretty easy now to build the kernel modules & your provided can-utils
we hopefully get some more feedback from j1939 users.

Best regards,
Oliver
