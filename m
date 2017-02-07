From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] bridge: improve cache utilization
Date: Mon, 06 Feb 2017 22:53:35 -0500 (EST)
Message-ID: <20170206.225335.2275258471740874933.davem@davemloft.net>
References: <1486227909-18319-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56954 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBGDxh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 22:53:37 -0500
In-Reply-To: <1486227909-18319-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Sat,  4 Feb 2017 18:05:05 +0100

> This is the first set which begins to deal with the bad bridge cache
> access patterns. The first patch rearranges the bridge and port structs
> a little so the frequently (and closely) accessed members are in the same
> cache line. The second patch then moves the garbage collection to a
> workqueue trying to improve system responsiveness under load (many fdbs)
> and more importantly removes the need to check if the matched entry is
> expired in __br_fdb_get which was a major source of false-sharing.
> The third patch is a preparation for the final one which
> If properly configured, i.e. ports bound to CPUs (thus updating "updated"
> locally) then the bridge's HitM goes from 100% to 0%, but even without
> binding we get a win because previously every lookup that iterated over
> the hash chain caused false-sharing due to the first cache line being
> used for both mac/vid and used/updated fields.
> 
> Some results from tests I've run:
> (note that these were run in good conditions for the baseline, everything
>  ran on a single NUMA node and there were only 3 fdbs)
> 
> 1. baseline
> 100% Load HitM on the fdbs (between everyone who has done lookups and hit
>                             one of the 3 hash chains of the communicating
>                             src/dst fdbs)
> Overall 5.06% Load HitM for the bridge, first place in the list
> 
> 2. patched & ports bound to CPUs
> 0% Local load HitM, bridge is not even in the c2c report list
> Also there's 3% consistent improvement in netperf tests.

Looks great, series applied, thanks!
