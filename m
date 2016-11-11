From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: [PATCH] Revert "include/uapi/linux/atm_zatm.h: include
 linux/time.h"
Date: Fri, 11 Nov 2016 11:12:09 +0200
Message-ID: <20161111091209.GE8342@lakka.kapsi.fi>
References: <20161111000839.23267-1-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:58936 "EHLO mail.kapsi.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965735AbcKKJMM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 04:12:12 -0500
Content-Disposition: inline
In-Reply-To: <20161111000839.23267-1-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Nov 10, 2016 at 07:08:39PM -0500, Mike Frysinger wrote:
> This reverts commit cf00713a655d ("include/uapi/linux/atm_zatm.h: include
> linux/time.h").
> 
> This attempted to fix userspace breakage that no longer existed when
> the patch was merged.  Almost one year earlier, commit 70ba07b675b5
> ("atm: remove 'struct zatm_t_hist'") deleted the struct in question.

Acked-by: Mikko Rapeli <mikko.rapeli@iki.fi>

Yep, sorry about this. My development branches are living for too long and
I should check each patch again before submitting. Simply rebasing is too easy.
Maybe Arnd could have spotted this earlier but scripts/get_maintainer.pl
didn't add him to Cc.

> After this patch was merged, we now have to deal with people being
> unable to include this header in conjunction with standard C library
> headers like stdlib.h (which linux-atm does).  Example breakage:
> x86_64-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I../.. -I./../q2931 -I./../saal \
> 	-I.  -DCPPFLAGS_TEST  -I../../src/include -O2 -march=native -pipe -g \
> 	-frecord-gcc-switches -freport-bug -Wimplicit-function-declaration \
> 	-Wnonnull -Wstrict-aliasing -Wparentheses -Warray-bounds \
> 	-Wfree-nonheap-object -Wreturn-local-addr -fno-strict-aliasing -Wall \
> 	-Wshadow -Wpointer-arith -Wwrite-strings -Wstrict-prototypes -c zntune.c
> In file included from /usr/include/linux/atm_zatm.h:17:0,
>                  from zntune.c:17:
> /usr/include/linux/time.h:9:8: error: redefinition of ‘struct timespec’
>  struct timespec {
>         ^
> In file included from /usr/include/sys/select.h:43:0,
>                  from /usr/include/sys/types.h:219,
>                  from /usr/include/stdlib.h:314,
>                  from zntune.c:9:
> /usr/include/time.h:120:8: note: originally defined here
>  struct timespec
>         ^

Well, this would help with the linux/time.h and glibc time.h conflicts:

https://patchwork.kernel.org/patch/9294305/

if linux/time.h is included after <time.h>.

Unfortunately I don't know when or if ever that will be applied.

-Mikko

> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  include/uapi/linux/atm_zatm.h | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/include/uapi/linux/atm_zatm.h b/include/uapi/linux/atm_zatm.h
> index 5cd4d4d2dd1d..9c9c6ad55f14 100644
> --- a/include/uapi/linux/atm_zatm.h
> +++ b/include/uapi/linux/atm_zatm.h
> @@ -14,7 +14,6 @@
>  
>  #include <linux/atmapi.h>
>  #include <linux/atmioc.h>
> -#include <linux/time.h>
>  
>  #define ZATM_GETPOOL	_IOW('a',ATMIOC_SARPRV+1,struct atmif_sioc)
>  						/* get pool statistics */
> -- 
> 2.9.0
> 
