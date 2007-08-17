From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in IPoIB
Date: Fri, 17 Aug 2007 11:36:03 +0530
Message-ID: <OFFFECFAD7.CF3FF115-ON6525733A.0020AE37-6525733A.00218365@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: gaagaan@gmail.com, general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:64242 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756633AbXHQGFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 02:05:12 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7H66rtB3276940
	for <netdev@vger.kernel.org>; Fri, 17 Aug 2007 16:06:53 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7H68POU177032
	for <netdev@vger.kernel.org>; Fri, 17 Aug 2007 16:08:25 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7H64nG5003868
	for <netdev@vger.kernel.org>; Fri, 17 Aug 2007 16:04:51 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Dave,

> I ran 3 iterations of 45 sec tests (total 1 hour 16 min, but I will
> run a longer one tonight). The results are (results in KB/s, and %):

I ran a 8.5 hours run with no batching + another 8.5 hours run with
batching (Buffer sizes: "32 128 512 4096 16384", Threads: "1 8 32",
Each test run time: 3 minutes, Iterations to average: 5). TCP seems
to get a small improvement.

Thanks,

- KK

-------------------------------------------------------------------------------
                           TCP
                        -----------
Size:32 Procs:1             3415       3321       -2.75
Size:128 Procs:1           13094      13388      2.24
Size:512 Procs:1            49037      50683      3.35
Size:4096 Procs:1          114646     114619     -.02
Size:16384 Procs:1        114626     114644     .01

Size:32 Procs:8             22675      22633      -.18
Size:128 Procs:8            77994      77297      -.89
Size:512 Procs:8            114716     114711     0
Size:4096 Procs:8          114637     114636     0
Size:16384 Procs:8         95814      114638     19.64

Size:32 Procs:32            23240      23349      .46
Size:128 Procs:32          82284      82247      -.04
Size:512 Procs:32          114885     114769     -.10
Size:4096 Procs:32         95735      114634     19.74
Size:16384 Procs:32       114736     114641     -.08

Average:                        1151534    1190210    3.36%
-------------------------------------------------------------------------------
                        No Delay:
                        ---------
Size:32 Procs:1             3002       2873       -4.29
Size:128 Procs:1           11853      11801      -.43
Size:512 Procs:1           45565      45837      .59
Size:4096 Procs:1         114511     114485     -.02
Size:16384 Procs:1        114521     114555     .02

Size:32 Procs:8             8026       8029       .03
Size:128 Procs:8           31589      31573      -.05
Size:512 Procs:8           111506     105766     -5.14
Size:4096 Procs:8         114455     114454     0
Size:16384 Procs:8        95833      114491     19.46

Size:32 Procs:32            8005       8027       .27
Size:128 Procs:32          31475      31505      .09
Size:512 Procs:32          114558     113687     -.76
Size:4096 Procs:32        114784     114447     -.29
Size:16384 Procs:32       114719     114496     -.19

Average:                         1046026    1034402    -1.11%
-------------------------------------------------------------------------------

