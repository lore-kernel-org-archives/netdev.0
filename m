From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Fri, 20 Nov 2009 15:39:13 -0800 (PST)
Message-ID: <20091120.153913.242783116.davem@davemloft.net>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46716
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753054AbZKTXi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 18:38:56 -0500
In-Reply-To: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 20 Nov 2009 15:28:58 -0800

> +		/* Schedule NAPI for backlog device */
> +		if (napi_schedule_prep(&queue->backlog)) {
> +			if (cpu != smp_processor_id()) {
> +				cpu_set(cpu,
> +				    get_cpu_var(rps_remote_softirq_cpus));
> +				__raise_softirq_irqoff(NET_RX_SOFTIRQ);
> +			} else
> +				__napi_schedule(&queue->backlog);
> +		}
> +		goto enqueue;
> +	}

I still think, like Jared, this should occur at the end of the NAPI
->poll() run.

Otherwise show us numbers indicating that it makes a big difference.
:-)
