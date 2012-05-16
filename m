From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] drop_monitor: convert to modular building
Date: Wed, 16 May 2012 16:48:01 +0200
Message-ID: <1337179681.8512.1212.camel@edumazet-glaptop>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53863 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301Ab2EPOsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 10:48:06 -0400
Received: by bkcji2 with SMTP id ji2so693246bkc.19
        for <netdev@vger.kernel.org>; Wed, 16 May 2012 07:48:05 -0700 (PDT)
In-Reply-To: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-16 at 10:27 -0400, Neil Horman wrote:
> When I first wrote drop monitor I wrote it to just build monolithically.  There
> is no reason it can't be built modularly as well, so lets give it that
> flexibiity.

> +	for_each_present_cpu(cpu) {
> +		data = &per_cpu(dm_cpu_data, cpu);
> +		del_timer(&data->send_timer);
> +		cancel_work_sync(&data->dm_alert_work);
> +		/*
> +		 * At this point, we should have exclusive access
> +		 * to this struct and can free the skb inside it
> +		 */
> +		kfree_skb(data->skb);
> +	}
> +

I dont think for_each_present_cpu(cpu) is right 

(I realize drop_monitor already uses this, but its a bug)

To use it, you must have a notifier to react to cpu HOTPLUG events.

-> for_each_possible_cpu() is more correct.

Also, please dont add new printk(KERN_WARNING ...), use pr_warn(...)
instead
