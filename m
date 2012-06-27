From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 23:35:47 +0200
Message-ID: <1340832947.26242.169.camel@edumazet-glaptop>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com>
	 <1340823810.26242.81.camel@edumazet-glaptop> <4FEB6B64.5060708@hp.com>
	 <1340829541.26242.90.camel@edumazet-glaptop>
	 <20120627135034.7db7d0eb@nehalam.linuxnetplumber.net>
	 <4FEB73EF.9090702@candelatech.com>
	 <1340832022.26242.131.camel@edumazet-glaptop>
	 <4FEB7BB9.1080905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>,
	Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, James Chapman <jchapman@katalix.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39139 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768Ab2F0Vfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 17:35:51 -0400
Received: by bkcji2 with SMTP id ji2so1476949bkc.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 14:35:50 -0700 (PDT)
In-Reply-To: <4FEB7BB9.1080905@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 14:31 -0700, Ben Greear wrote:

> For an example, see the VLAN code. rx-errors and tx-dropped are only 32-bit
> counters.  Now, in the real world, we wouldn't expect those counters to
> increase at high rates, but they are still 32-bit counters masquerading
> as 64, and they could wrap after a while, so any code that expected a wrap
> to mean a 64-bit wrap would be wrong.
> 
> At the time I was last complaining, there were lots more cases
> of this that I was fighting with, but I don't recall exactly what they
> were.  Once my user-space code got paranoid enough, it was able to
> at least mostly deal with 32 and 64 wraps.

Good, you now know how to deal correctly with these things.

Using 64bit fields for tx_dropped is what I call kernel bloat.

If only all drops were correctly accounted...

I believe 50% of drivers are buggy in this aspect.
