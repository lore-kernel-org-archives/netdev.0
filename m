From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net: Reduce queue allocation to one in kdump kernel
Date: Thu, 9 Jun 2016 15:06:23 -0700
Message-ID: <CAM_iQpUyPeZM3VtTg_k3TFGjmCYhgjh16TY6iu=JXBJfZEYH1Q@mail.gmail.com>
References: <1465389548-7651-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	nirranjan@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:36034 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932493AbcFIWGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 18:06:44 -0400
Received: by mail-yw0-f193.google.com with SMTP id l126so6434963ywe.3
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 15:06:43 -0700 (PDT)
In-Reply-To: <1465389548-7651-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 8, 2016 at 5:39 AM, Hariprasad Shenai
<hariprasad@chelsio.com> wrote:
> When in kdump kernel, reduce memory usage by only using a single Queue
> Set for multiqueue devices. So make netif_get_num_default_rss_queues()
> return one, when in kdump kernel.
>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
>  net/core/dev.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 904ff431d570..161c4627a798 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -139,6 +139,7 @@
>  #include <linux/hrtimer.h>
>  #include <linux/netfilter_ingress.h>
>  #include <linux/sctp.h>
> +#include <linux/crash_dump.h>
>
>  #include "net-sysfs.h"
>
> @@ -2249,7 +2250,8 @@ EXPORT_SYMBOL(netif_set_real_num_rx_queues);
>   */
>  int netif_get_num_default_rss_queues(void)
>  {
> -       return min_t(int, DEFAULT_MAX_NUM_RSS_QUEUES, num_online_cpus());
> +       return is_kdump_kernel() ?
> +               1 : min_t(int, DEFAULT_MAX_NUM_RSS_QUEUES, num_online_cpus());

IIRC, kdump kernel already uses cpus=1, or at least you can tell how many
CPU's you want in kdump config.

This change doesn't make any sense to me, we don't want to check
for kdump for every of such places, do we?
