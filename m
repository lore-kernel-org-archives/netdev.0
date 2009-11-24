From: Tom Herbert <therbert@google.com>
Subject: NUMA and multiQ interation
Date: Tue, 24 Nov 2009 09:04:41 -0800
Message-ID: <65634d660911240904y294ea6fj4cf2e4ac757e619b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:42525 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932454AbZKXREk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 12:04:40 -0500
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id nAOH4iCm029654
	for <netdev@vger.kernel.org>; Tue, 24 Nov 2009 17:04:44 GMT
Received: from pwj13 (pwj13.prod.google.com [10.241.219.77])
	by zps37.corp.google.com with ESMTP id nAOH4RmY014539
	for <netdev@vger.kernel.org>; Tue, 24 Nov 2009 09:04:41 -0800
Received: by pwj13 with SMTP id 13so4883953pwj.18
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2009 09:04:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a question about the expected interaction between NUMA and
receive multi queue.=A0 Our test setup is a 16 core AMD system with 4
sockets, one NUMA node per socket and a bnx2x.=A0 The test is running
500 streams in netperf RR with response/request of one byte using
net-next-2.6.

Highest throughput we are seeing is with 4 queues (1 queue processed
per socket) giving 361862 tps at 67% of cpu.=A0 16 queues (1 queue per
cpu) gives 226722 tps at 30.43% cpu.

However, with a modified kernel that does RX skb allocations from
local node rather than the devices numa node, I'm getting 923422 tps
at 100% cpu.=A0 This is much higher tps and better cpu utilization than
the case where allocations are coming from the device numa node.  It
appears that cross node allocations are a causing a significant
performance hit.  For a 2.5 times performance improvement I'm kind of
motivated to revert netdev_alloc_skb to when it did not pay attention
to numa node :-)

What is the expected interaction here, and would these results be
typical?  If so, would this warrant the need to associate each RX
queue to a numa node, instead of just the device?

Thanks,
Tom
