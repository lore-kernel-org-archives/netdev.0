From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: RE: [RFC/PATCH] net: add deferred flow cache flush function to be
Date: Mon, 26 Sep 2011 19:58:54 +0300
Message-ID: <1317056334-23521-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<timo.teras@iki.fi>, Madalin Bucur <madalin.bucur@freescale.com>
To: <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:39583
	"EHLO AM1EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751380Ab1IZQ7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 12:59:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've investigated this issue further and come up with a different fix -
modify the flow_cache_flush to prevent it from sleeping and also remove the
deferral of the actual gc work through schedule_work. That caused the gc never
to happen on a highly loaded system that had the cpus occupied servicing
network softirqs.

During the investigation I've also found two places the return value of 
dst_alloc was used without checking, leading to a crash. 

The 3 patches will follow.


> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On 
> Behalf Of Eric Dumazet
>
> Problem is sometime we dont want to defer and are in process context.
> 
> xfrm_dev_event(  event == NETDEV_DOWN) is probably a place we dont want
> to defer the garbage collection.
