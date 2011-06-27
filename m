From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6 1/3] be2net: fix netdev_stats_update
Date: Mon, 27 Jun 2011 09:43:37 -0700
Message-ID: <20110627094337.5108b5f6@nehalam.ftrdhcpuser.net>
References: <4da4117c-a24a-4512-9b79-fbed126e03bc@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40340 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752577Ab1F0Qnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 12:43:40 -0400
In-Reply-To: <4da4117c-a24a-4512-9b79-fbed126e03bc@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Jun 2011 12:10:48 +0530
Sathya Perla <sathya.perla@emulex.com> wrote:

> Problem initially reproted and fixed by Eric Dumazet <eric.dumazet@gmail.com>
> 
> netdev_stats_update() resets netdev->stats and then accumulates stats from
> various rings. This is wrong as stats readers can sometimes catch zero values.
> Use temporary variables instead for accumulating per-ring values.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Should also use u64_stats_sync to ensure correct rollover or 32 bit SMP
platform.
