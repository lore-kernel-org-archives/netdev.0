From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH][RFC/v1][8/12] Add IPoIB
	(IP-over-InfiniBand) driver
Date: Mon, 22 Nov 2004 20:40:03 +0100
Message-ID: <20041122194003.GC8150@mars.ravnborg.org>
References: <20041122713.FnSlYodJYum7s82D@topspin.com>
	<20041122714.nKCPmH9LMhT0X7WE@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <roland@topspin.com>
Content-Disposition: inline
In-Reply-To: <20041122714.nKCPmH9LMhT0X7WE@topspin.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

More nitpicking..

	Sam
	
> +++ linux-bk/drivers/infiniband/Makefile	2004-11-21 21:25:56.794775182 -0800
> @@ -1,2 +1,3 @@
>  obj-$(CONFIG_INFINIBAND)		+= core/
No reason to use $(CONFIG_INFINIBAND) here - it's already done in
drivers/infiniband/Makefile

> +EXTRA_CFLAGS += -Idrivers/infiniband/include
This will get killed if you move the include files...

 +
> +obj-$(CONFIG_INFINIBAND_IPOIB)			+= ib_ipoib.o
> +
> +ib_ipoib-y					:= ipoib_main.o \
> +						   ipoib_ib.o \
> +						   ipoib_multicast.o \
> +						   ipoib_verbs.o \
> +						   ipoib_vlan.o
One or two lines.

> +#include <asm/semaphore.h>
> +
> +#include "ipoib_proto.h"
Shoulb be included as the last file - since it's the most local one.
> +
> +#include <ib_verbs.h>
> +#include <ib_pack.h>
> +#include <ib_sa.h>
> 
