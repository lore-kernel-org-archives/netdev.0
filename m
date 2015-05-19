From: Ido Shamay <idos@dev.mellanox.co.il>
Subject: Re: Default XPS settings in mlx4 driver
Date: Wed, 20 May 2015 01:20:48 +0300
Message-ID: <555BB740.20708@dev.mellanox.co.il>
References: <CALx6S36qXcqhfFQVLWu2CgoJYQL6E-myvgBvDFxATA+NjX+qBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Benjamin Poirier <bpoirier@suse.de>
To: Tom Herbert <tom@herbertland.com>, Ido Shamay <idos@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:36076 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbbESWUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 18:20:52 -0400
Received: by wgbgq6 with SMTP id gq6so33455416wgb.3
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 15:20:50 -0700 (PDT)
In-Reply-To: <CALx6S36qXcqhfFQVLWu2CgoJYQL6E-myvgBvDFxATA+NjX+qBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/19/2015 11:38 PM, Tom Herbert wrote:
> Hi Ido,
>
> I'm looking at your patch "net/mlx4_en: Configure the XPS queue
> mapping on driver load". We're testing a 40 CPU system and it looks
> like XPS is being configured by default with forty queues 0-39 where
> each xps_cpus is (1 << i). The problem is that this does not easily
> align with RX queues and the TX completion interrupt for TX queue z
> happens in interrupt for (z % num_rx_queues). So it looks like, the
> default XPS doesn't respect the RX interrupt affinities, so we have TX
> queues that are bound to a CPU on one numa node but have their TX
> completions happen on another which is suboptimal. It would be nice if
> the default XPS could take where the completion interrupt happens into
> account somehow.
Hi Tom,

Actually this was changed lately in "42eab005 mlx4: (Fix tx ring 
affinity_mask creation)"
by Benjamin Poirier, to match the default affinity hints we give for the 
RX interrupts.

Back then I tested all kinds of schemes and found certain tradeoffs.
Having 1:1 mapping of tx rings selection (xmit) and CPUs (decoupled from 
the completion affinity)
correlates good sender application cores selection and was found to have 
benefits in certain scenarios.
In general the affinity of IRQs might be changed from the hints, so XPS 
should be configured to desired
scheme (sysfs).
Certainly more research is required to find the optimal setting for the 
common case.

Regards,
Ido
