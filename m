From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/12] benet: net_object i/f functions, Makefile
Date: Thu, 19 Jun 2008 06:13:06 -0400
Message-ID: <20080619101306.GB17697@infradead.org>
References: <20080612104007.d68b14bd@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:55834 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755011AbYFSKNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 06:13:08 -0400
Content-Disposition: inline
In-Reply-To: <20080612104007.d68b14bd@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2008 at 03:40:07AM -0700, Subbu Seetharaman wrote:
> --- /dev/null
> +++ b/drivers/net/benet/Makefile
> @@ -0,0 +1,22 @@
> +#
> +# Makefile to build the network driver for ServerEngine's BladeEngine.
> +#
> +BECLIBPATH = $(src)/../../message/beclib
> +
> +EXTRA_CFLAGS = -Wno-unknown-pragmas -DFUNCTION_NIC -I$(BECLIBPATH) \
> +	-I$(BECLIBPATH)/fw -I$(BECLIBPATH)/fw/amap -I$(BECLIBPATH)/fw/bmap 

No driver-specific compiler paramters and defines on the command line
please.  Also please don't add gazillions of include pathes.  You'd be
much better off just having this in one directory.

> +
> +obj-$(CONFIG_BENET) 	:= benet.o

Please use += instead of := here.

> +
> +benet-objs	:=  be_init.o be_int.o be_netif.o be_ethtool.o bni.o \
> +	../../message/beclib/funcobj_ll.o  \
> +	../../message/beclib/chipobj_ll.o \
> +	../../message/beclib/cq_ll.o \
> +	../../message/beclib/eq_ll.o \
> +	../../message/beclib/main_ll.o \
> +	../../message/beclib/mpu_ll.o \

You'll make your life a lot easier if you just keep all objects build
into a single module in one directory.

