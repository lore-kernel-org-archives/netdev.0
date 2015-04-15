From: rapier <rapier@psc.edu>
Subject: [Question] TCP stack performance decrease since 3.14
Date: Wed, 15 Apr 2015 15:31:52 -0400
Message-ID: <552EBCA8.6090408@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:39560 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754913AbbDOUXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 16:23:37 -0400
Received: from iztli.psc.edu (iztli.psc.edu [128.182.160.106])
	(authenticated bits=0)
	by mailer1.psc.edu (8.13.8/8.13.8) with ESMTP id t3FJVqC1010985
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 15:31:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All,

First, my apologies if this came up previously but I couldn't find 
anything using a keyword search of the mailing list archive.

As part of the on going work with web10g I need to come up with baseline 
TCP stack performance for various kernel revision. Using netperf and 
super_netperf* I've found that performance for TCP_CC, TCP_RR, and 
TCP_CRR has decreased since 3.14.

	3.14	3.18	4.0 	decrease %
TCP_CC	183945	179222	175793	4.4%
TCP_RR	594495	585484	561365	5.6%
TCP_CRR	98677	96726	93026	5.7%

Stream tests have remained the same from 3.14 through 4.0.

All tests were conducted on the same platform from clean boot with stock 
kernels.

So my questions are:

Has anyone else seen this or is this a result of some weirdness on my 
system or artifact of my tests?

If others have seen this or is just simply to be expected (from new 
features and the like) is it due to the TCP stack itself or other 
changes in the kernel?

If so, is there anyway to mitigate the effect of this via stack tuning, 
kernel configuration, etc?

Thanks!

Chris


* The above results are the average of 10 iterations of super_netperf 
for each test. I can run more iterations to verify the results but it 
seem consistent. The number of parallel processes for each test was 
tuned to produce the maximum test result. In other words, enough to push 
things but not enough to cause performance hits due to being 
cpu/memory/etc bound. If anyone wants the full results and test scripts 
just let me know.
