From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 net-next 4/8] net/ncsi: Add debugging infrastructurre
Date: Tue, 18 Apr 2017 09:22:14 +1000
Message-ID: <20170417232214.GA3569@gwshan>
References: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1492069701-20772-5-git-send-email-gwshan@linux.vnet.ibm.com>
 <1492080106.28586.13.camel@perches.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:54830 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752636AbdDQXXQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 19:23:16 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3HNIsMX029149
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 19:23:16 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29w0p6f3ps-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 19:23:15 -0400
Received: from localhost
        by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 18 Apr 2017 09:23:13 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
        by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3HNN3ks66388132
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 09:23:11 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
        by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3HNMdpK008847
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 09:22:39 +1000
Content-Disposition: inline
In-Reply-To: <1492080106.28586.13.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 03:41:46AM -0700, Joe Perches wrote:
>On Thu, 2017-04-13 at 17:48 +1000, Gavin Shan wrote:
>> This creates debugfs directories as NCSI debugging infrastructure.
>> With the patch applied, We will see below debugfs directories. Every
>> NCSI package and channel has one corresponding directory. Other than
>> presenting the NCSI topology, No real function has been achieved
>> through these debugfs directories so far.
>> 
>>      /sys/kernel/debug/ncsi/eth0
>>      /sys/kernel/debug/ncsi/eth0/p0
>>      /sys/kernel/debug/ncsi/eth0/p0/c0
>>      /sys/kernel/debug/ncsi/eth0/p0/c1
>
>[]
>
>> diff --git a/net/ncsi/ncsi-debug.c b/net/ncsi/ncsi-debug.c
>[]
>> +int ncsi_dev_init_debug(struct ncsi_dev_priv *ndp)
>> +{
>> +	if (WARN_ON_ONCE(ndp->dentry))
>> +		return 0;
>> +
>> +	if (!ncsi_dentry) {
>> +		ncsi_dentry = debugfs_create_dir("ncsi", NULL);
>> +		if (!ncsi_dentry) {
>> +			pr_warn("NCSI: Cannot create /sys/kernel/debug/ncsi\n");
>> +			return -ENOENT;
>
>debugfs does not have a fixed path.
>
>Most error messages for this just use something like
>	pr_<level>("Failed to create debugfs directory '%s'\n", foo)
>And most failures don't emit any error message at all.
>

Thanks, Joe. I will correct in next respin.

Thanks,
Gavin
