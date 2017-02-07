From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Performance in stmmac
Date: Tue, 7 Feb 2017 19:33:52 +0000
Message-ID: <1d4da3b4-d798-e55a-3988-647adbfd8413@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: <niklas.cassel@axis.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:33808 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752003AbdBGTd5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 14:33:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi to all,

I finished implementing the multi-queue / multi-channel in stmmac and I am now
making some tests.

The mechanism is working properly, but the performance could be better
(~440Mb/s) :). For measuring I am using iperf:

synopsys@pt02ipk1:~$ iperf -c 192.168.0.3 --port 5001 -t 20 -i 5
------------------------------------------------------------
Client connecting to 192.168.0.3, TCP port 5001
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  3] local 192.168.0.2 port 34272 connected with 192.168.0.3 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 5.0 sec   260 MBytes   436 Mbits/sec
[  3]  5.0-10.0 sec   262 MBytes   440 Mbits/sec
[  3] 10.0-15.0 sec   262 MBytes   440 Mbits/sec
[  3] 15.0-20.0 sec   257 MBytes   431 Mbits/sec
[  3]  0.0-20.0 sec  1.02 GBytes   437 Mbits/sec

I am seeing tx being performed in all queues, but rx is just being routed to
queue 0. The reason why only queue 0 is processing the packets is because I am
using priority tagged routing for now and iperf is not capable of producing
priority tagged traffic.

I am sending you this e-mail in order to know if you could suggest me a tool to
generate priority tagged traffic and if you have experience in tweaking stmmac
to improve performance.

Thanks,
Joao
