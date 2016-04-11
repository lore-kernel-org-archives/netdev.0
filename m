From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: avoid refreshing heartbeat timer too often
Date: Sun, 10 Apr 2016 22:23:32 -0400 (EDT)
Message-ID: <20160410.222332.1053521794879934365.davem@davemloft.net>
References: <7aa05d5d8b9100fa48798b43887de6d14d577eac.1459966346.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, vyasevich@gmail.com,
	David.Laight@ACULAB.COM, linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbcDKCXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 22:23:38 -0400
In-Reply-To: <7aa05d5d8b9100fa48798b43887de6d14d577eac.1459966346.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed,  6 Apr 2016 15:15:19 -0300

> Currently on high rate SCTP streams the heartbeat timer refresh can
> consume quite a lot of resources as timer updates are costly and it
> contains a random factor, which a) is also costly and b) invalidates
> mod_timer() optimization for not editing a timer to the same value.
> It may even cause the timer to be slightly advanced, for no good reason.
> 
> As suggested by David Laight this patch now removes this timer update
> from hot path by leaving the timer on and re-evaluating upon its
> expiration if the heartbeat is still needed or not, similarly to what is
> done for TCP. If it's not needed anymore the timer is re-scheduled to
> the new timeout, considering the time already elapsed.
> 
> For this, we now record the last tx timestamp per transport, updated in
> the same spots as hb timer was restarted on tx. Also split up
> sctp_transport_reset_timers into sctp_transport_reset_t3_rtx and
> sctp_transport_reset_hb_timer, so we can re-arm T3 without re-arming the
> heartbeat one.
> 
> On loopback with MTU of 65535 and data chunks with 1636, so that we
> have a considerable amount of chunks without stressing system calls,
> netperf -t SCTP_STREAM -l 30, perf looked like this before:
 . ..
> And after this patch, now with netperf -l 60:
 ...
> Throughput-wise, from 6800mbps without the patch to 7050mbps with it,
> ~3.7%.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thanks Marcelo.
