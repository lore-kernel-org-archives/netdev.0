From: Christoph Lameter <cl@linux.com>
Subject: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 12:10:01 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904161151330.13531@qirst.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:57355 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754773AbZDPQRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 12:17:05 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8F78482C28B
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 12:26:58 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5lOI8KaE0fYT for <netdev@vger.kernel.org>;
	Thu, 16 Apr 2009 12:26:52 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 27FBA82C16C
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 12:26:52 -0400 (EDT)
Received: from cl (helo=localhost)
	by qirst.com with local-esmtp (Exim 4.69)
	(envelope-from <cl@linux.com>)
	id 1LuUA5-0002dv-AX
	for netdev@vger.kernel.org; Thu, 16 Apr 2009 12:10:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following are results of lantency measurements using udpping
(available from http://gentwo.org/ll). It shows that significant latencies
were added since 2.6.27. I surely wish we could get back to times below 90
microseconds.

The tests were done over 1G ethernet using
09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5754
Gigabit Ethernet PCI Express (rev 02)

Results:

           2.6.22 2.6.23 2.6.24 2.6.25 2.6.26 2.6.27 2.6.28 2.6.29
40 Bytes    89.50  90.75  89.61  91.51  91.89  99.17  99.80  99.34
400 Bytes   98.58 101.44  97.85  99.61 100.36 117.96 118.10 126.79
1400 Bytes 152.76 153.75 153.85	156.22 156.66 163.92 165.54 166.04

Compared to 2.6.22 2.6.23 2.6.24 2.6.25 2.6.26 2.6.27 2.6.28 2.6.29
40 Bytes            -1.4%  -0.1%  -2.2%  -2.6%  -9.8%  -10.3% -9.9%
400 Bytes           -2.8%   0.7%  -1.0%  -1.8% -16.4%  -16.5%-22.2%
1400 Bytes          -0.6%  -0.7%  -2.2%  -2.5%  -6.8%  -7.7%  -8.0%

I presented these numbers with some nice graphs at the Linux Collab Summit
last week.

See
http://www.kernel.org/pub/linux/kernel/people/christoph/collab-spring-2009/Collab-summit-2009-sf.pdf

