From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] mlx4: set carrier off after register netdev
Date: Fri, 5 Oct 2012 21:53:35 +0100
Message-ID: <1349470415.2819.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <alpine.LNX.2.00.1210051058420.16216@linux-acr3.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Min Zhang <mzhang@mvista.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1210051058420.16216@linux-acr3.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-10-05 at 11:28 -0700, Min Zhang wrote:
> ifconfig mlx4_en port reported RUNNING even though the link was down.
> 
> mlx4_en_init_netdev didn't initialize the dev operstate properly so
> the operstate stayed as default IF_OPER_UNKNOWN, then ifconfig treated
> the UNKNOWN as RUNNING state for backward compatiblity per RFC2863.
> 
> The fix calls netif_carrier_off which is supposed to set operstate
> after register_netdev. Calling it before register_netdev has no effect
> since the dev->state is still NETREG_UNINITIALIZED
> 
> Tested by removing the physical link signal to the mellanox 10G port,
> modprobe mlx4_en, then ifconfig up. Verify there is no RUNNING status.
[...]

This was supposed to be fixed by:

commit 8f4cccbbd92f2ad0ddbbc498ef7cee2a1c3defe9
Author: Ben Hutchings <bhutchings@solarflare.com>
Date:   Mon Aug 20 22:16:51 2012 +0100

    net: Set device operstate at registration time

Does that not work for mlx4_en, for some reason?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
