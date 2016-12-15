From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 1/3] ifstat: Add extended statistics to
 ifstat
Date: Thu, 15 Dec 2016 09:33:27 -0800
Message-ID: <20161215093327.2daf60c6@xeon-e3>
References: <1481806845-63384-1-git-send-email-nogahf@mellanox.com>
        <1481806845-63384-2-git-send-email-nogahf@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        jiri@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        idosch@mellanox.com, ogerlitz@mellanox.com
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33343 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751845AbcLORdf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 12:33:35 -0500
Received: by mail-pg0-f47.google.com with SMTP id 3so22136259pgd.0
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 09:33:35 -0800 (PST)
In-Reply-To: <1481806845-63384-2-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Dec 2016 15:00:43 +0200
Nogah Frankel <nogahf@mellanox.com> wrote:

> Extended stats are part of the RTM_GETSTATS method. This patch adds them
> to ifstat.
> While extended stats can come in many forms, we support only the
> rtnl_link_stats64 struct for them (which is the 64 bits version of struct
> rtnl_link_stats).
> We support stats in the main nesting level, or one lower.
> The extension can be called by its name or any shorten of it. If there is
> more than one matched, the first one will be picked.
> 
> To get the extended stats the flag -x <stats type> is used.
> 
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  misc/ifstat.c | 161 ++++++++++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 146 insertions(+), 15 deletions(-)
> 
> diff --git a/misc/ifstat.c b/misc/ifstat.c
> index 92d67b0..d17ae21 100644
> --- a/misc/ifstat.c
> +++ b/misc/ifstat.c
> @@ -35,6 +35,7 @@
>  
>  #include <SNAPSHOT.h>
>  
> +#include "utils.h"
>  int dump_zeros;
>  int reset_history;
>  int ignore_history;

Minor nit, please cleanup include order here (original code was wrong).

Standard practice is:
 #include system headers (like stdio.h etc)
 #include "xxx.h" local headers.

Should be:
#include <getopt.h>

#include <linux/if.h>
#include <linux/if_link.h>

#include "json_writer.h"
#include "libnetlink.h"
#include "utils.h"
#include "SNAPSHOT.h"
