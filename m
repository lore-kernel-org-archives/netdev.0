From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 net-next 5/8] net/ncsi: Dump NCSI packet statistics
Date: Tue, 18 Apr 2017 10:14:19 +1000
Message-ID: <20170418001419.GA11300@gwshan>
References: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1492069701-20772-6-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170413185042.0e69cb71@cakuba.lan>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        joe@perches.com, davem@davemloft.net
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:60192 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752870AbdDRAPW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 20:15:22 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3I0E11p006503
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 20:15:21 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29vwf496m2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 20:15:21 -0400
Received: from localhost
        by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 18 Apr 2017 10:15:18 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3I0F8Fg55902218
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 10:15:16 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
        by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3I0EgSv018236
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 10:14:43 +1000
Content-Disposition: inline
In-Reply-To: <20170413185042.0e69cb71@cakuba.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 06:50:42PM -0700, Jakub Kicinski wrote:
>On Thu, 13 Apr 2017 17:48:18 +1000, Gavin Shan wrote:
>> This creates /sys/kernel/debug/ncsi/<eth0>/stats to dump the NCSI
>> packets sent and received over all packages and channels. It's useful
>> to diagnose NCSI problems, especially when NCSI packages and channels
>> aren't probed properly. The statistics can be gained from debugfs file
>> as below:
>> 
>>  # cat /sys/kernel/debug/ncsi/eth0/stats
>> 
>>  CMD          OK       TIMEOUT  ERROR
>>  =======================================
>>  CIS          32       29       0
>>  SP           10       7        0
>>  DP           17       14       0
>>  EC           1        0        0
>>  ECNT         1        0        0
>>  AE           1        0        0
>>  GLS          11       0        0
>>  SMA          1        0        0
>>  EBF          1        0        0
>>  GVI          2        0        0
>>  GC           2        0        0
>> 
>>  RSP          OK       TIMEOUT  ERROR
>>  =======================================
>>  CIS          3        0        0
>>  SP           3        0        0
>>  DP           2        0        1
>>  EC           1        0        0
>>  ECNT         1        0        0
>>  AE           1        0        0
>>  GLS          11       0        0
>>  SMA          1        0        0
>>  EBF          1        0        0
>>  GVI          0        0        2
>>  GC           2        0        0
>> 
>>  AEN          OK       TIMEOUT  ERROR
>>  =======================================
>> 
>> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
>
>I'm not familiar with NC-SI but these look like some standard stats.
>Would it make sense to provide a proper netlink API for them?
>
>[...]
>> +#ifdef CONFIG_NET_NCSI_DEBUG
>> +		ndp->stats.aen[h->type][NCSI_PKT_STAT_ERROR]++;
>> +#endif
>
>In any case, did you consider creating a macro or inline helper to
>limit the number of #ifdefs?
>

Jakub, thanks for the comments. NCSI does have standard statistics
about the packets passed to peer (NIC) or NCSI packets handled by
hardware. I have some patches (not posted yet and won't post in
this merge window) to create debugfs file ncsi/eth0/p0/c0/stats
and dump them there.

This debugfs tracks NCSI packets sent and received by software
in order to see if the software has obvious bugs.

Yeah, it's definitely worthy to eliminate the #ifdef's. I'll do
in next respin.

Thanks,
Gavin
