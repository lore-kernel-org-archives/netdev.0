From: Eric Leblond <eric@regit.org>
Subject: eBPF: how to check the flow table
Date: Sun, 18 Sep 2016 14:02:15 +0200
Message-ID: <1474200135.19872.12.camel@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:41856 "EHLO home.regit.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754166AbcIRM26 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 08:28:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm currently testing a code implementing AF_PACKET bypass for
Suricata. The idea is that Suricata is updating a hash table containing
a list of flows it does not want to see anymore.

I want to check flow timeout from the userspace, so my current
algorithm is doing:

    while (bpf_get_next_key(mapfd, &key, &next_key) == 0) {
        bpf_lookup_elem(mapfd, &next_key, &value);
        FlowCallback(mapfd, &next_key, &value, data);
        key = next_key;
    }

In the FlowCallback, I check the timing in the flow entry and I remove
the key if the flow is timeout.

This is currently working well when there is only a few flows but on a
real system with log of insertion in the table, the loop is never
returning because we dequeue slower than we enqueue.

Is there a better algorithm or an other way to do it ? 

BR,
-- 
Eric Leblond <eric@regit.org>
Blog: https://home.regit.org/
