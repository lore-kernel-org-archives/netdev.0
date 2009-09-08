From: Christoph Lameter <cl@linux-foundation.org>
Subject: UDP regression with packets rates < 10k per sec
Date: Tue, 8 Sep 2009 18:38:39 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:41977 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751089AbZIHWjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 18:39:36 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4ACF682C408
	for <netdev@vger.kernel.org>; Tue,  8 Sep 2009 18:40:30 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mOm5G0bZqSGm for <netdev@vger.kernel.org>;
	Tue,  8 Sep 2009 18:40:24 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E062D82C407
	for <netdev@vger.kernel.org>; Tue,  8 Sep 2009 18:40:24 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like we have a regression since 2.6.22 due to latency increases in
the network stack? The following is the result of measuring latencies for
UDP multicast traffic at packet rates of 10pps 100pps 1kpps 10kpps and
100k pps. Two system running "mcast -n1 -r<rate>" (mcast tool from
http://gentwo.org/ll).

Measurements in microseconds for one hop using bnx2 on Dell R610 (64 bit
2.6.31-rc9) and Dell 1950 (32 bit 2.6.22.19 3.3Ghz). Dell R610 RX usecs
tuned to 0. 32 bit tuned to 1 (NIC is flaky at 0).

Kernel			10pps	100pps	1kpps	10kpps	100kpps
---------------------------------------------------------------
2.6.22 (32bit)		30	29.5	29	30	41
2.6.31-rc9(64 bit)	64	63	46	30	40

The only minor improvement is at a rate of 100kpps. All rates
lower than 10k regress significantly.

Could there be something wrong with the bnx2 interrupt routing? They all
end up on cpu0 here. There are 8 of them in a system with 16 "processors".
How do those need to be configured? There are some sparse comments in
Documentation/networking/multiqueue.txt but the text does not say anything
about the irq routing.


