From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] xen-netfront: always keep the Rx ring full
 of requests
Date: Fri, 24 Oct 2014 00:50:58 -0400 (EDT)
Message-ID: <20141024.005058.2073408669277403704.davem@davemloft.net>
References: <1413973026-6475-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46472 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbaJXEvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 00:51:00 -0400
In-Reply-To: <1413973026-6475-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Wed, 22 Oct 2014 11:17:06 +0100

> A full Rx ring only requires 1 MiB of memory.  This is not enough
> memory that it is useful to dynamically scale the number of Rx
> requests in the ring based on traffic rates, because:
> 
> a) Even the full 1 MiB is a tiny fraction of a typically modern Linux
>    VM (for example, the AWS micro instance still has 1 GiB of memory).
> 
> b) Netfront would have used up to 1 MiB already even with moderate
>    data rates (there was no adjustment of target based on memory
>    pressure).
> 
> c) Small VMs are going to typically have one VCPU and hence only one
>    queue.
> 
> Keeping the ring full of Rx requests handles bursty traffic better
> than trying to converge on an optimal number of requests to keep
> filled.
> 
> On a 4 core host, an iperf -P 64 -t 60 run from dom0 to a 4 VCPU guest
> improved from 5.1 Gbit/s to 5.6 Gbit/s.  Gains with more bursty
> traffic are expected to be higher.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
> Changes in v2:
> - Keep rxbuf_* sysfs files.

Applied.
