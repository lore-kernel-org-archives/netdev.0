From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 1/10] cxgb3 - FW versioning
Date: Wed, 31 Jan 2007 18:09:58 -0800
Message-ID: <45C14BF6.50309@chelsio.com>
References: <20070131034345.8574.21031.stgit@localhost.localdomain> <45C07202.3090308@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <None@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:28421 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161082AbXBACKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 21:10:06 -0500
In-Reply-To: <45C07202.3090308@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Please see my replies in line.
> You need to submit a patch to remove the following ioctls:
>
> CHELSIO_SETREG:
> CHELSIO_GETREG:

These will get removed.

> CHELSIO_SET_QSET_PARAMS: (use ethtool instead)
> CHELSIO_GET_QSET_PARAMS: (use ethtool instead)

The T3 adapter supports multiple Tx/Rx queue sets,
each can be can individually configured through these ioctls.

ethtool is not adequate replacement because it can't configure
each queue individually on such a device. We'd love it if ethtool
were to be extended to provide good support for multi queue devices.

> CHELSIO_SET_QSET_NUM: (use ethtool instead)
> CHELSIO_GET_QSET_NUM: (use ethtool instead)

These are used to set the number of queue sets per port.
That also could be integrated in ethtool if extended
to add support for multiple queue devices.
We could alternatively use a sysfs attribute.

> CHELSIO_SETMTUTAB:

This one is needed to setup the device for RDMA.

> CHELSIO_GET_MEM:

This one is used for field diagnostics.
It dumps the state of on-card memory.

> CHELSIO_SET_TRACE_FILTER:

This one is used for RDMA.
It allows to see the ethernet packets the RDMA function
puts on the wire/receives from the wire.

> CHELSIO_SET_PKTSCHED:

This one binds a queue set to a port.
It could be turned to a sysfs attribute.

>
> explain and possibly remove
>
> CHELSIO_GET_PM:
> CHELSIO_SET_PM:

These are used to configure the on-card memory (tx/rx size
and number of pages). They could be turned into sysfs attributes.

Cheers,
Divy
