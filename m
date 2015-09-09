From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v5 02/10] ss: created formatters for json and hr
Date: Wed, 9 Sep 2015 08:27:38 -0700
Message-ID: <20150909082738.19b52ea9@urahara>
References: <1441130243-20303-1-git-send-email-matthias.tafelmeier@gmx.net>
	<a84873c9a97b40868529f203587ecfc5@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"shemminger@osdl.org" <shemminger@osdl.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"edumazet@google.com" <edumazet@google.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34870 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909AbbIIP12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 11:27:28 -0400
Received: by pacfv12 with SMTP id fv12so13548470pac.2
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 08:27:28 -0700 (PDT)
In-Reply-To: <a84873c9a97b40868529f203587ecfc5@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Sep 2015 17:57:15 +0000
Matthias Tafelmeier <matthias.tafelmeier@gmx.net> wrote:

> diff --git a/misc/ss_out_fmt.h b/misc/ss_out_fmt.h
> new file mode 100644
> index 0000000..fa29cec
> --- /dev/null
> +++ b/misc/ss_out_fmt.h
> @@ -0,0 +1,82 @@
> +#ifndef SS_OUT_FMT_H
> +#define SS_OUT_FMT_H
> +
> +#include "ss_hr_fmt.h"
> +#include "ss_json_fmt.h"
> +#include "ss_types.h"
> +#include <linux/inet_diag.h>
> +#include <linux/pkt_sched.h>
> +#include <linux/filter.h>
> +#include <linux/netdevice.h>
> +#include <linux/packet_diag.h>
> +
> +#define GENERIC_DETAIL 0
> +#define NETLINK_DETAIL 1
> +
> +#define STATIC_ASSERT(COND, MSG) char STATIC_ASSERT##MSG[(COND) ? 1 : -1]

This form of ASSERT generates unused variable warnings and is unacceptable.

Could you instead do something like kernel and other code.

/**
 * Triggers an error at compilation time if the condition is true.
 */
#define BUILD_BUG_ON(condition) ((void)sizeof(char[1 - 2*!!(condition)]))

#endif
