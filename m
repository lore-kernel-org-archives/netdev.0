From: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Subject: router advertisement processing.
Date: Mon, 9 Jul 2012 16:35:40 +0000
Message-ID: <4A71D24947E78D43BC584A7CD4391A41017D73EB@HKNPRD0410MB350.apcprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:6026
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752163Ab2GIQgJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2012 12:36:09 -0400
Received: from mail71-ch1 (localhost [127.0.0.1])	by mail71-ch1-R.bigfish.com
 (Postfix) with ESMTP id 1BB952C029E	for <netdev@vger.kernel.org>; Mon,  9 Jul
 2012 16:33:32 +0000 (UTC)
Received: from CH1EHSMHS021.bigfish.com (snatpool1.int.messaging.microsoft.com
 [10.43.68.250])	by mail71-ch1.bigfish.com (Postfix) with ESMTP id F049C4C01E1
	for <netdev@vger.kernel.org>; Mon,  9 Jul 2012 16:33:28 +0000 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear all,

    I am running tahi IPv6 ready-logo test suite (www.tahi.org) in kernel-3.0.26. Currently I am facing a problem in RFC-4861. The test cases 145, 147 and 149 fails. All three test cases are related to processing the Router Advertisements (ra).

    The setup is having a tester node (tn: a FreeBSD machine) and a node under test (nut: a target board running kernel-3.0.26).

    In test case 145, the tn will send a ra with curhoplimit=64. And will send a ICMP request to the nut. Then tn will receive the ICMP reply from nut and check its hoplimit for 64. Then it will send another ra with curhoplimit=0 (the tn expects this ra should be ignored). Again will a send an ICMP request to check the hoplimit of ICMP reply from nut. The tn expects the reply should have the same hoplimit, 64 as it wants the later ra should be ignored.

    But In my case, the nut doesn't use the value given in the curhoplimit from the tn. Instead for the first ICMP reply it uses the value of /proc/sys/net/ipv6/conf/eth0/hop_limit and for the later ICMP reply it uses the value 255 as hoplimit. So this test case fails. I read the source net/ipv6/ndisc.c and net/ipv6/icmp.c.

    In ndisc.c line 1285, the curhoplimit value is stored. But while preparing ICMP reply, to determine the hoplimit (in route.c line number: 1162), the function ip6_dst_hoplimit, gets the dst_metric_raw and returns that value. But that value becomes 255 once the ra with 0 received.

   And 147 and 149. Both test cases are related to one concept. The tn  sends router advertisement (ra) with some time limit. And it continuously sends ICMP request till the time expires. And also some seconds even after the time expires.  The tn expects that the nut should not reply to the ICMP request after the time expires. But the nut does reply.  In net/ipv6/icmp.c, I can't find the code checking for the time expiry. Also in net/ipv6/ndisc.c I can't find the value lifetime (line no: 1234) got stored in the dst->metrics array.

    I furnished this mail as per my understanding. I am very newbie to kernel code. Frankly speaking, this is my first encounter with kernel source. So there is a very good chance for me to be wrong. Please direct me in right path if I am wrong. Kindly help me to solve this issue.


Thank you all.

--Regards,
K.Balakumaran
+91 7406 479 544
