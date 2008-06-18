From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: Re: [PATCH 3/12] benet: net_object i/f functions, Makefile
Date: Wed, 18 Jun 2008 09:20:41 -0700
Message-ID: <20080618162041.9395b269@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: "Sam Ravnborg" <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail142.messagelabs.com ([216.82.249.99]:42013 "EHLO
	mail142.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbYFRQUq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 12:20:46 -0400
In-Reply-To: 20080617192610.GB12961@uranus.ravnborg.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sam,

We could not find any good way to eliminate the unsresolved
symbol warnings with the message code separated as
a module. Also, is there a way to prevent
configuration of "y" for benet and "m" for beclib ?

What is the advantage of using benet-y instead
of benet-objs ?  I do not see net driver makefile
using *-y. 

Thanks.

Subbu



----- Original Message -----
From: Sam Ravnborg [mailto:sam@ravnborg.org]
To: Subbu Seetharaman [mailto:subbus@serverengines.com]
Cc: jeff@garzik.org, netdev@vger.kernel.org
Sent: Tue, 17 Jun 2008 12:26:10 -0700
Subject: Re: [PATCH 3/12] benet: net_object i/f functions, Makefile


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
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

