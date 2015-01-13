From: Eyal Perry <eyalpe@dev.mellanox.co.il>
Subject: BW regression after "tcp: refine TSO autosizing"
Date: Tue, 13 Jan 2015 18:48:50 +0200
Message-ID: <54B54C72.8060705@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	yevgenyp@mellanox.com, saeedm@mellanox.com, idos@mellanox.com,
	amira@mellanox.com, eyalpe@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:42687 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbbAMQyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 11:54:15 -0500
Received: by mail-wg0-f46.google.com with SMTP id x13so4110556wgg.5
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 08:54:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,
Lately we've observed performance degradation in BW of about 30-40% (depends on
the setup we use).
I've bisected the issue down to the this commit: 605ad7f1 ("tcp: refine TSO
autosizing")

For instance, I was running the following test:
1. Bounding net device' irqs to core 0 for both client and server side
2. Running netperf with 64K massage size (used the following command)
$ netperf -H remote -T 1,1 -l 100 -t TCP_STREAM -- -k THROUGHPUT -M 65536 -m 65536

I ran the test on upstream net-next including your patch and than reverted it
and these are the results I got was improvement from 14.6Gbps to 22.1Gbps.

an additional difference I've noticed when inspecting the ethtool statics,
number of xmit_more packets increased from 4 to 160 with the reverted kernel.

We are investigating this issue, do you have a hint?

Best regards,
Eyal.
