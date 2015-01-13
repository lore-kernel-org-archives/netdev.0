From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Tue, 13 Jan 2015 10:57:14 -0800
Message-ID: <1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54B54C72.8060705@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	yevgenyp@mellanox.com, saeedm@mellanox.com, idos@mellanox.com,
	amira@mellanox.com, eyalpe@mellanox.com
To: Eyal Perry <eyalpe@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:39935 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbbAMS5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 13:57:16 -0500
Received: by mail-ie0-f169.google.com with SMTP id y20so4574437ier.0
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 10:57:15 -0800 (PST)
In-Reply-To: <54B54C72.8060705@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-13 at 18:48 +0200, Eyal Perry wrote:
> Hello Eric,
> Lately we've observed performance degradation in BW of about 30-40% (depends on
> the setup we use).
> I've bisected the issue down to the this commit: 605ad7f1 ("tcp: refine TSO
> autosizing")
> 
> For instance, I was running the following test:
> 1. Bounding net device' irqs to core 0 for both client and server side
> 2. Running netperf with 64K massage size (used the following command)
> $ netperf -H remote -T 1,1 -l 100 -t TCP_STREAM -- -k THROUGHPUT -M 65536 -m 65536
> 
> I ran the test on upstream net-next including your patch and than reverted it
> and these are the results I got was improvement from 14.6Gbps to 22.1Gbps.
> 
> an additional difference I've noticed when inspecting the ethtool statics,
> number of xmit_more packets increased from 4 to 160 with the reverted kernel.
> 
> We are investigating this issue, do you have a hint?

Which driver are you using for this test ?
