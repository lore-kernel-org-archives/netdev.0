From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 23:50:49 +0200
Message-ID: <1340833849.26242.186.camel@edumazet-glaptop>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com>
	 <1340823810.26242.81.camel@edumazet-glaptop> <4FEB6B64.5060708@hp.com>
	 <1340829541.26242.90.camel@edumazet-glaptop>
	 <20120627135034.7db7d0eb@nehalam.linuxnetplumber.net>
	 <4FEB73EF.9090702@candelatech.com>
	 <1340832022.26242.131.camel@edumazet-glaptop>
	 <1340832771.26242.160.camel@edumazet-glaptop>
	 <4FEB7DC0.9090404@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>,
	Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, James Chapman <jchapman@katalix.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34666 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368Ab2F0Vuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 17:50:55 -0400
Received: by bkcji2 with SMTP id ji2so1485828bkc.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 14:50:54 -0700 (PDT)
In-Reply-To: <4FEB7DC0.9090404@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 14:40 -0700, Ben Greear wrote:

> Notice that the netlink stats are claiming 64-bit and they are not
> (always) 64-bit.


There is no such claim.

netlink provides a 64bit generic binary holder, even for legacy drivers
still using 'unsigned long' stats, so obviously 32bit values on 32bit
kernels.

> That is a nice binary API that is still wrapping before its time
> in many cases.  There may be good performance reasons for keeping
> some counters at 32-bit, but it plays merry hell with anyone wanting
> to optimize an application to poll less often for stats that are
> supposedly 64-bit.

We dont want hundred of patches to bring 64bit stats on legacy drivers. 

Nobody cares, because its way too late to try to 'fix' this.

If you want your application running on linux-2.6.x, or linux-3.0, you
are forced to correctly detect each counter being 32 or 64, not because
netlink API is 64bit, but because a driver provides a 32 or 64 bit
value.
