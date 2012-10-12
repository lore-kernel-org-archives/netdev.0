From: Animesh K Trivedi1 <ZRLATR@ch.ibm.com>
Subject: performance regression with skb_add_data_nocache
Date: Fri, 12 Oct 2012 16:29:17 +0200
Message-ID: <OF2F004787.31D0FC5A-ONC1257A95.004517AF-C1257A95.004F9973@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Bernard Metzler <BMT@zurich.ibm.com>,
	Animesh K Trivedi1 <ZRLATR@ch.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:42669 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932973Ab2JLO3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 10:29:30 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zrlatr@ch.ibm.com>;
	Fri, 12 Oct 2012 15:29:28 +0100
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9CETIQF61079572
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2012 14:29:18 GMT
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9CDqdod004588
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2012 09:52:39 -0400
Received: from d06ml359.portsmouth.uk.ibm.com (d06ml359.portsmouth.uk.ibm.com [9.149.76.147])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q9CDqdqO004585
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2012 09:52:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

I recently upgraded from 2.6.36 to 3.2.28 and saw performance regression
for
TCP performance. Upon further investigation it looked that
skb_add_data_nocache()
was the culprit.

I am getting following performance numbers on my Nehalem (Xeon E7520) box
connected using 10GbE cards (transmit side, and netperf client). Server is
a another
box with E5540 CPU (receiver of the request) . For my netperf TCP_RR tests:

-  1,400 bytes request, 1 byte response:
No cache copy (enabled)  : 26,623 tps, 22.72% utilization
No cache copy (disabled) : 26,710 tps, 21.76% utilization

- 14,000 bytes request, 1 byte response:
No cache copy (enabled)  : 14,245 tps, 23.04% utilization
No cache copy (disabled) : 14,850 tps, 21.6% utilization

and for even larger buffer the performance lag is increases with
significant CPU load

- 1 MBytes request, 1 byte response:
No cache copy (enabled)  : 1,032 tps, 98.96% utilization
No cache copy (disabled) : 1,081 tps, 74.86% utilization

Though there isn't a lot performance difference, but notice the significant
CPU
utilization in case of nocache copy for 1MB buffer size. Thoughts?

Thanks,
--
Animesh
