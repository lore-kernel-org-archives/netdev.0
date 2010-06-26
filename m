From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 10/10] enic: Clean ups
Date: Fri, 25 Jun 2010 20:49:32 -0700 (PDT)
Message-ID: <20100625.204932.241449443.davem@davemloft.net>
References: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
	<20100624205213.22595.97942.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scofeldm@cisco.com, roprabhu@cisco.com
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49968
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752436Ab0FZDtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 23:49:20 -0400
In-Reply-To: <20100624205213.22595.97942.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Thu, 24 Jun 2010 13:52:26 -0700

> diff --git a/drivers/net/enic/vnic_wq.c b/drivers/net/enic/vnic_wq.c
> index 3ab7fa5..5c84bb8 100644
> --- a/drivers/net/enic/vnic_wq.c
> +++ b/drivers/net/enic/vnic_wq.c
> @@ -1,5 +1,5 @@
>  /*
> - * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
> + * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
>   * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
>   *
>   * This program is free software; you may redistribute it and/or modify
> @@ -22,7 +22,6 @@
>  #include <linux/types.h>
>  #include <linux/pci.h>
>  #include <linux/delay.h>
> -#include <linux/slab.h>
>  
>  #include "vnic_dev.h"
>  #include "vnic_wq.h"

I have to remove this otherwise the build breaks:

drivers/net/enic/vnic_wq.c: In function 'vnic_wq_alloc_bufs':
drivers/net/enic/vnic_wq.c:39:3: error: implicit declaration of function 'kzalloc'
drivers/net/enic/vnic_wq.c:39:15: warning: assignment makes pointer from integer without a cast
drivers/net/enic/vnic_wq.c: In function 'vnic_wq_free':
drivers/net/enic/vnic_wq.c:79:3: error: implicit declaration of function 'kfree'
  CC [M]  drivers/net/sfc/mcdi_mac.o
make[3]: *** [drivers/net/enic/vnic_wq.o] Error 1
make[3]: *** Waiting for unfinished jobs....
  CC [M]  drivers/net/sfc/selftest.o
  CC [M]  drivers/net/sfc/ethtool.o
  CC [M]  drivers/net/sfc/qt202x_phy.o
drivers/net/enic/vnic_rq.c: In function 'vnic_rq_alloc_bufs':
drivers/net/enic/vnic_rq.c:39:3: error: implicit declaration of function 'kzalloc'
drivers/net/enic/vnic_rq.c:39:15: warning: assignment makes pointer from integer without a cast
drivers/net/enic/vnic_rq.c: In function 'vnic_rq_free':
drivers/net/enic/vnic_rq.c:79:3: error: implicit declaration of function 'kfree'

Any time you remove any header includes, it is very wise to attempt a wide
assortment of build tests using all sorts of different configurations.
