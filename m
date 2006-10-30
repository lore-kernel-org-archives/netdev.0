From: Ben Greear <greearb@candelatech.com>
Subject: pktgen patch available for perusal.
Date: Mon, 30 Oct 2006 15:47:58 -0800
Message-ID: <45468F2E.4060809@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:680 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1422748AbWJ3XsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 18:48:05 -0500
To: NetDev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've completed the first pass of my changes to pktgen in 2.6.18.
Many of these features are probably DOA based on previous conversations,
but perhaps this will help someone....

Changes:
* use a nano-second timer based on the scheduler timer (TSC) for relative times, instead of get_time_of_day.
* Don't busy-spin:
    * add hook to netdevice wake tx queue to re-start when queue was stopped.
    * add logic to pktgen to register/unregister this hook.
    * accumulate delay and sleep interruptible on a queue when 1ms of sleep has accumulated
      or when the associated netdev tx-queues for pktgen devices needing to transmit are asleep.
    (This all assumes that HZ is 1000, could probably work with other HZ with minor work.)
* Add receive logic to dev.c so that pktgen can receive packets and report on various stats
   including latency, packet loss, jitter, etc.
* Remove the if-lock, primarily by making the 'add-interface' logic deferred to the
   thread's main loop.  It's likely I missed a corner case or two here, hopefully I'll
   find them all in testing...
* Add ioctl to grab all of the pktgen stats in one call.

The pktgen.[ch] patch is here:  http://www.candelatech.com/oss/pktgen.patch

The full patch, including the callback hooks (and several other features)
is located here:  http://www.candelatech.com/oss/candela_2.6.18.patch

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

