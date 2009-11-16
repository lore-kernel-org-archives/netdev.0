From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Mon, 16 Nov 2009 03:19:14 -0800 (PST)
Message-ID: <20091116.031914.65020185.davem@davemloft.net>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57042
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751134AbZKPLS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 06:18:58 -0500
In-Reply-To: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 10 Nov 2009 22:53:17 -0800

> +		/* Schedule NAPI for backlog device */
> +		if (napi_schedule_prep(&queue->backlog)) {
> +			if (cpu != smp_processor_id()) {
> +				cpu_set(cpu,
> +				    get_cpu_var(rps_remote_softirq_cpus));
> +				__raise_softirq_irqoff(NET_RPS_SOFTIRQ);
> +			} else
> +				__napi_schedule(&queue->backlog);
> +		}
> +		goto enqueue;

{,__}send_remote_softirq() doesn't work? :-)
