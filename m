From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v5] netfilter: Xtables: idletimer target implementation
Date: Tue, 15 Jun 2010 13:54:25 +0200
Message-ID: <4C1769F1.40506@trash.net>
References: <1276593679-9576-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	jengelh@medozas.de, Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276593679-9576-1-git-send-email-luciano.coelho@nokia.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two final comments:

Luciano Coelho wrote:
> diff --git a/include/linux/netfilter/xt_IDLETIMER.h b/include/linux/netfilter/xt_IDLETIMER.h
> new file mode 100644
> index 0000000..3e1aa1b
> --- /dev/null
> +++ b/include/linux/netfilter/xt_IDLETIMER.h

This file needs to be added to Kbuild to make sure it gets installed
during "make headers_install".

> +static void idletimer_tg_destroy(const struct xt_tgdtor_param *par)
> +{
> +	const struct idletimer_tg_info *info = par->targinfo;
> +
> +	pr_debug("destroy targinfo %s\n", info->label);
> +
> +	mutex_lock(&list_mutex);
> +	if (!info->timer) {
>   

This doesn't seem to be possible.

> +		mutex_unlock(&list_mutex);
> +		return;
> +	}
> +
> +	if (--info->timer->refcnt == 0) {
> +		pr_debug("deleting timer %s\n", info->label);
> +
> +		list_del(&info->timer->entry);
> +		del_timer_sync(&info->timer->timer);
> +		sysfs_remove_file(idletimer_tg_kobj, &info->timer->attr.attr);
> +		kfree(info->timer->attr.attr.name);
> +		kfree(info->timer);
> +	} else {
> +		pr_debug("decreased refcnt of timer %s to %u\n",
> +			 info->label, info->timer->refcnt);
> +	}
> +
> +	mutex_unlock(&list_mutex);
> +}

