From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add support for device specific address syncing
Date: Fri, 23 May 2014 14:55:35 -0400 (EDT)
Message-ID: <20140523.145535.35857476092197009.davem@davemloft.net>
References: <20140521205457.31151.8273.stgit@ahduyck-cp2.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jpirko@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbaEWSzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 14:55:37 -0400
In-Reply-To: <20140521205457.31151.8273.stgit@ahduyck-cp2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 21 May 2014 13:55:15 -0700

> This change provides a function to be used in order to break the
> ndo_set_rx_mode call into a set of address add and remove calls.  The code
> is based on the implementation of dev_uc_sync/dev_mc_sync.  Since they
> essentially do the same thing but with only one dev I simply named my
> functions __dev_uc_sync/__dev_mc_sync.
> 
> I also implemented an unsync version of the functions as well to allow for
> cleanup on close.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

This looks fine semantically to me.

Please fix the coding style issues below and submit this alongside
the changes for whatever driver will first make use of this.

Thanks!

> +int __hw_addr_sync_dev(struct netdev_hw_addr_list *list,
> +		struct net_device *dev,
> +		int (*sync)(struct net_device *, const unsigned char *),
> +		int (*unsync)(struct net_device *, const unsigned char *));

Arguments on continuation lines should start at the first column after
the openning parenthesis on the first line.  You must use the appropriate
number of TAB and SPACE characters necessary to achieve this.

> +void __hw_addr_unsync_dev(struct netdev_hw_addr_list *list,
> +		struct net_device *dev,
> +		int (*unsync)(struct net_device *, const unsigned char *));

Likewise.

> +static inline int __dev_uc_sync(struct net_device *dev,
> +		int (*sync)(struct net_device *, const unsigned char *),
> +		int (*unsync)(struct net_device *, const unsigned char *))

Likewise.

> +static inline void __dev_uc_unsync(struct net_device *dev,
> +		   int (*unsync)(struct net_device *, const unsigned char *))

Likewise.

> +static inline int __dev_mc_sync(struct net_device *dev,
> +		int (*sync)(struct net_device *, const unsigned char *),
> +		int (*unsync)(struct net_device *, const unsigned char *))

Likewise.

> +static inline void __dev_mc_unsync(struct net_device *dev,
> +		int (*unsync)(struct net_device *, const unsigned char *))

Likewise.

> +int __hw_addr_sync_dev(struct netdev_hw_addr_list *list,
> +		struct net_device *dev,
> +		int (*sync)(struct net_device *, const unsigned char *),
> +		int (*unsync)(struct net_device *, const unsigned char *))

Likewise.

> +void __hw_addr_unsync_dev(struct netdev_hw_addr_list *list,
> +		struct net_device *dev,
> +		int (*unsync)(struct net_device *, const unsigned char *))

Likewise.
