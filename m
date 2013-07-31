From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 0/5] bonding: groundwork and initial conversion
 to RCU
Date: Wed, 31 Jul 2013 17:39:36 +0200
Message-ID: <51F92FB8.1090000@redhat.com>
References: <1375283553-32070-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, davem@davemloft.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41604 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756599Ab3GaPnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 11:43:12 -0400
In-Reply-To: <1375283553-32070-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2013 05:12 PM, Nikolay Aleksandrov wrote:
<snip>
>  For performance notes please refer to patch 5 (RCU conversion one).
> 
Oops, I've forgotten to include the performance tests, here they are:
2 slaves were used in all tests.

1. Active-backup mode
 1.1 Perf recording while doing iperf -P 4
  - old bonding: iperf spent 0.55% in bonding, system spent 0.29% CPU
                 in bonding
  - new bonding: iperf spent 0.29% in bonding, system spent 0.15% CPU
                 in bonding
 1.2. Bandwidth measurements
  - old bonding: 16.1 gbps consistently
  - new bonding: 17.5 gbps consistently

2. Round-robin mode
 2.1 Perf recording while doing iperf -P 4
  - old bonding: iperf spent 0.51% in bonding, system spent 0.24% CPU
                 in bonding
  - new bonding: iperf spent 0.16% in bonding, system spent 0.11% CPU
                 in bonding
 2.2 Bandwidth measurements
  - old bonding: 8 gbps (variable due to packet reorderings)
  - new bonding: 10 gbps (variable due to packet reorderings)


Of course the latency has improved in all converted modes, and moreover while
doing enslave/release (since it doesn't affect tx anymore).

Also I've stress tested all modes doing enslave/release in a loop while
transmitting traffic.

Cheers,
 Nik
> Best regards,
>  Nikolay Aleksandrov
<snip>
