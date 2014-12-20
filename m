From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet adapters
Date: Sat, 20 Dec 2014 01:33:50 +0100
Message-ID: <5494C3EE.6090707@gmx.de>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com> <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:52028 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752087AbaLTAdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2014 19:33:54 -0500
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19.12.2014 04:25, Raghu Vatsavayi wrote:
> +sleep_cond(wait_queue_head_t *wait_queue, int *condition)
> +{
> +	wait_queue_t we;
> +
> +	init_waitqueue_entry(&we, current);
> +	add_wait_queue(wait_queue, &we);
> +	set_current_state(TASK_INTERRUPTIBLE);
> +	while (!(ACCESS_ONCE(*condition)))
> +		schedule();
> +	set_current_state(TASK_RUNNING);
> +	remove_wait_queue(wait_queue, &we);
> +}

This looks as if we should at least check for pending signals, otherwise
there is no point in waiting interruptible.
Maybe wait_event_interruptible() is what we really want here...

Regards,
Lino
