From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2 1/3] ethtool: Introduce n-tuple filter
 programming support
Date: Thu, 04 Feb 2010 09:18:54 -0800 (PST)
Message-ID: <20100204.091854.24215476.davem@davemloft.net>
References: <20100204074811.16559.84676.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41672
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754008Ab0BDRSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 12:18:40 -0500
In-Reply-To: <20100204074811.16559.84676.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 03 Feb 2010 23:48:13 -0800

> +#define ETHTOOL_RXNTUPLE_ACTION_DROP -1
> +	struct list_head list;
> +};

You can't do this.

You put the list_head here in the kernel header, which BTW can
be used by userspace too, and then you elide it in the
ethtool utility copy of the header.

Use an encapsulator if you must inside of the kernel, but keep the
userspace visible data structure clean of RCU and list_head
kernel datastructures.

Thanks.

