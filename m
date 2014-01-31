From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH] net: ipv4: move inetpeer garbage collector work to
 power efficient workqueue
Date: Fri, 31 Jan 2014 17:10:58 +0400
Message-ID: <52EBA0E2.7050208@cogentembedded.com>
References: <1391125213-8119-1-git-send-email-zoran.markovic@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaibal Dutta <shaibal.dutta@broadcom.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Zoran Markovic <zoran.markovic@linaro.org>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:49797 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932146AbaAaNKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 08:10:49 -0500
Received: by mail-lb0-f180.google.com with SMTP id n15so3312455lbi.25
        for <netdev@vger.kernel.org>; Fri, 31 Jan 2014 05:10:48 -0800 (PST)
In-Reply-To: <1391125213-8119-1-git-send-email-zoran.markovic@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 31-01-2014 3:40, Zoran Markovic wrote:

> From: Shaibal Dutta <shaibal.dutta@broadcom.com>

> Garbage collector work does not have to be bound to the CPU that scheduled
> it. By moving work to the power-efficient workqueue, the selection of
> CPU executing the work is left to the scheduler. This extends idle
> residency times and conserves power.

> This functionality is enabled when CONFIG_WQ_POWER_EFFICIENT is selected.

> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Shaibal Dutta <shaibal.dutta@broadcom.com>
> [zoran.markovic@linaro.org: Rebased to latest kernel version. Added
> commit message.]
> Signed-off-by: Zoran Markovic <zoran.markovic@linaro.org>
> ---
>   net/ipv4/inetpeer.c |    6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)

> diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
> index 48f4244..87155aa 100644
> --- a/net/ipv4/inetpeer.c
> +++ b/net/ipv4/inetpeer.c
> @@ -161,7 +161,8 @@ static void inetpeer_gc_worker(struct work_struct *work)
>   	list_splice(&list, &gc_list);
>   	spin_unlock_bh(&gc_lock);
>
> -	schedule_delayed_work(&gc_work, gc_delay);
> +	queue_delayed_work(system_power_efficient_wq,
> +		&gc_work, gc_delay);

    Please align the continuation line under the next character after ( on the 
broken up line.

> @@ -576,7 +577,8 @@ static void inetpeer_inval_rcu(struct rcu_head *head)
>   	list_add_tail(&p->gc_list, &gc_list);
>   	spin_unlock_bh(&gc_lock);
>
> -	schedule_delayed_work(&gc_work, gc_delay);
> +	queue_delayed_work(system_power_efficient_wq,
> +		&gc_work, gc_delay);

    Same here. This is according to networking coding style.

WBR, Sergei
