From: Ben Greear <greearb@candelatech.com>
Subject: Performance issue with igb with lots of different src-ip addrs.
Date: Thu, 16 Mar 2017 15:49:03 -0700
Message-ID: <58CB165F.7030302@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: e1000-devel list <e1000-devel@lists.sourceforge.net>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:51734 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751321AbdCPWjS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 18:39:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We notice that when using two igb ports as a bridge, if we use pktgen to
drive traffic through the bridge and randomize (or use a very large range)
for the source IP addr in pktgen, then performance of igb is very poor (like 150Mbps
throughput instead of 1Gbps).  It runs right at line speed if we use same src/dest
IP addr in pktgen.  So, seems it is related to lots of src/dest IP addresses.

We see same problem when using pktgen to send to itself, and we see this in
several different kernels.  We specifically tested bridge mode in this stock
Fedora kernel:

  Linux lfo350-59cc 4.9.13-101.fc24.x86_64 #1 SMP Tue Mar 7 23:48:32 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux

e1000e does not show this problem in our testing.

Any ideas what the issue might be and how to fix it?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
