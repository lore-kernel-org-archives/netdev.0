From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: Multicast packet loss
Date: Tue, 10 Mar 2009 19:22:45 -0400
Message-ID: <49B6F645.2070408@athenacr.com>
References: <20090204012144.GC3650@localhost.localdomain>	<49A6CE39.5050200@athenacr.com>	<49A8FAFF.7060104@cosmosbay.com> <20090304.001646.100690134.davem@davemloft.net> <49AE3DA9.2020103@cosmosbay.com> <49B2266C.9050701@cosmosbay.com> <49B3F655.6030308@cosmosbay.com> <49B59EA3.3000208@athenacr.com> <49B5FA84.9000301@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kchang@athenacr.com, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:1024 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753364AbZCJXWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 19:22:49 -0400
In-Reply-To: <49B5FA84.9000301@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

FYI: with your patch applied and lockdep enabled, I see:
[   39.114628] ================================================
[   39.121964] [ BUG: lock held when returning to user space! ]
[   39.127704] ------------------------------------------------
[   39.133461] msgtest/5242 is leaving the kernel with locks still held!
[   39.140132] 1 lock held by msgtest/5242:
[   39.144287]  #0:  (clock-AF_INET){-.-?}, at: [<ffffffff8041f5b9>] sock_def_readable+0x19/0xb0

I can't reproduced this with the mcasttest program yet, it
was with an internal test program which does some userspace
processing on the messages. I'll let you know if I find a way
to reproduce it with a simple program I can share.

 > Well, smp_affinity could help in my opininon if you dedicate
 > one cpu for the NIC, and others for user apps, if the average
 > work done per packet is large. If load is light, its better
 > to use the same cpu to perform all the work, since no expensive
 > bus trafic is needed between cpu to exchange memory lines.

I tried this setup as well: an 8-core box with 4 userspace
processes, each affined to an individual CPU1-4. The IRQ was on
CPU0. On most kernels, this setup loses fewer packets than the default
affinity (though they both lose some). With your patch enabled, the
default affinity loses 0 packets, and this setup loses some.

Thanks,
Brian Bloniarz

