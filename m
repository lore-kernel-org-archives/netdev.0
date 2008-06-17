From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 3/12] benet: net_object i/f functions, Makefile
Date: Tue, 17 Jun 2008 21:26:10 +0200
Message-ID: <20080617192610.GB12961@uranus.ravnborg.org>
References: <20080612104007.d68b14bd@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:40898 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757013AbYFQTZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 15:25:41 -0400
Content-Disposition: inline
In-Reply-To: <20080612104007.d68b14bd@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2008 at 03:40:07AM -0700, Subbu Seetharaman wrote:
> Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
> ---
>  drivers/net/benet/Makefile |   22 +
>  drivers/net/benet/bni.c    | 1177 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 1199 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/benet/Makefile
>  create mode 100644 drivers/net/benet/bni.c
> 
> diff --git a/drivers/net/benet/Makefile b/drivers/net/benet/Makefile
> new file mode 100644
> index 0000000..0fe3297
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
> +
> +obj-$(CONFIG_BENET) 	:= benet.o
> +
> +benet-objs	:=  be_init.o be_int.o be_netif.o be_ethtool.o bni.o \
> +	../../message/beclib/funcobj_ll.o  \
> +	../../message/beclib/chipobj_ll.o \
> +	../../message/beclib/cq_ll.o \
> +	../../message/beclib/eq_ll.o \
> +	../../message/beclib/main_ll.o \
> +	../../message/beclib/mpu_ll.o \
> +	../../message/beclib/ethrx_ll.o \
> +	../../message/beclib/ethtx_ll.o \
> +	../../message/beclib/rxf_ll.o


I would have expected the message support to be implmented as a separate
module with a nice interface used by benet.
This would also kill the above misuse of kbuild.

No matter what you do then please use:
benet-y := be_init.o be_int.o be_netif.o be_ethtool.o ...
as replacement for benet-objs := ....

	Sam
