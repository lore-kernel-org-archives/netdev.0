From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 8/8] orinoco: New driver - spectrum_cs.
Date: Tue, 6 Sep 2005 12:24:24 +0100
Message-ID: <20050906112424.GA5309@infradead.org>
References: <1125619806.29016.11.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1125619806.29016.11.camel@dv>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

> +#ifdef  __IN_PCMCIA_PACKAGE__
> +#include <pcmcia/k_compat.h>
> +#endif /* __IN_PCMCIA_PACKAGE__ */

this doesn't make sense for a 2.6 driver.

> +/*
> + * If SPECTRUM_FW_INCLUDED is defined, the firmware is hardcoded into
> + * the driver.  Use get_symbol_fw script to generate spectrum_fw.h and
> + * copy it to the same directory as spectrum_cs.c.
> + *
> + * If SPECTRUM_FW_INCLUDED is not defined, the firmware is loaded at the
> + * runtime using hotplug.  Use the same get_symbol_fw script to generate
> + * files symbol_sp24t_prim_fw symbol_sp24t_sec_fw, copy them to the
> + * hotplug firmware directory (typically /usr/lib/hotplug/firmware) and
> + * make sure that you have hotplug installed and enabled in the kernel.
> + */
> +/* #define SPECTRUM_FW_INCLUDED 1 */
> +
> +#ifdef SPECTRUM_FW_INCLUDED
> +/* Header with the firmware */
> +#include "spectrum_fw.h"
> +#else	/* !SPECTRUM_FW_INCLUDED */

While I see the point of this for the standalone orinoco driver package
it doesn't make sense for the version in the kernel tree.

> +#define CS_CHECK(fn, ret) \
> +  do { last_fn = (fn); if ((last_ret = (ret)) != 0) goto cs_failed; } while (0)

I don't think this macro abuse helps anyone..



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
