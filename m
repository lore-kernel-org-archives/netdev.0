From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 14:57:17 -0700
Message-ID: <1239919037.12883.15.camel@HP1>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com>
 <49E78A79.6050604@cosmosbay.com>
 <alpine.DEB.1.10.0904161553160.23632@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Christoph Lameter" <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3503 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751228AbZDPWDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 18:03:03 -0400
In-Reply-To: <alpine.DEB.1.10.0904161553160.23632@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2009-04-16 at 12:55 -0700, Christoph Lameter wrote:
> On Thu, 16 Apr 2009, Eric Dumazet wrote:
> 
> > Is it a bnx2 or tg3 driver ?
> 
> bnx2.
> 
> > It would be sane to always set on both machines :
> > ethtool -C eth0 rx-usecs 0 rx-frames 1
> > prior to your tests...
> 
> rx-usecs is set to 18 by default by the driver and rx-frames is set to 6.
> We saw some funky behavior with rx-usecs 0 so we left the defaults.

We haven't changed these defaults since the beginning, but firmware
updates between 2.6.22 and 2.6.29 can affect latency.

Yes, Eric is right, using rx-frames 1 will give the best latency number.
(rx-usecs won't matter if rx-frames is set to 1).

> 
> But what does it matter? Just changing the kernel should not cause
> increases in latency.
> 

It will not matter if you use the same out-of-tree driver when switching
kernels.  If you use in-tree driver, the firmware may have changed
between kernel versions.



