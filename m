From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 net-next 5/8] net/ncsi: Dump NCSI packet statistics
Date: Tue, 18 Apr 2017 09:23:49 +1000
Message-ID: <20170417232349.GB3569@gwshan>
References: <1492069701-20772-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1492069701-20772-6-git-send-email-gwshan@linux.vnet.ibm.com>
 <1492080640.28586.15.camel@perches.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:55434 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752900AbdDQXYy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 19:24:54 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3HNIvxT043557
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 19:24:53 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29w00kgspf-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 19:24:53 -0400
Received: from localhost
        by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 18 Apr 2017 09:24:49 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3HNOdmS5046558
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 09:24:47 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
        by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3HNOEiY015421
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 09:24:14 +1000
Content-Disposition: inline
In-Reply-To: <1492080640.28586.15.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 03:50:40AM -0700, Joe Perches wrote:
>On Thu, 2017-04-13 at 17:48 +1000, Gavin Shan wrote:
>> This creates /sys/kernel/debug/ncsi/<eth0>/stats to dump the NCSI
>> packets sent and received over all packages and channels. It's useful
>> to diagnose NCSI problems, especially when NCSI packages and channels
>> aren't probed properly.
>
>trivia:
>
>> diff --git a/net/ncsi/ncsi-debug.c b/net/ncsi/ncsi-debug.c
>> index 6c00e9b..29c233c 100644
>> --- a/net/ncsi/ncsi-debug.c
>> +++ b/net/ncsi/ncsi-debug.c
>> @@ -23,6 +23,235 @@
>>  #include "ncsi-pkt.h"
>>  
>>  static struct dentry *ncsi_dentry;
>> +static struct ncsi_pkt_handler {
>
>static const struct etc...
>

Yes.

>> +	unsigned char	type;
>> +	const char	*name;
>> +} ncsi_pkt_handlers[] = {
>> +	{ NCSI_PKT_CMD_CIS,    "CIS"    },
>[]
>> +static bool ncsi_dev_stats_index(struct ncsi_dev_priv *ndp, loff_t pos,
>> +				 unsigned long *type, unsigned long *index,
>> +				 unsigned long *entries)
>> +{
>> +	int i;
>> +	unsigned long ranges[3][2] = {
>> +		{ 1,
>> +		  ARRAY_SIZE(ndp->stats.cmd) - 1		},
>> +		{ ranges[0][1] + 2,
>> +		  ranges[1][0] + ARRAY_SIZE(ndp->stats.rsp) - 1	},
>> +		{ ranges[1][1] + 2,
>> +		  ranges[2][0] + ARRAY_SIZE(ndp->stats.aen) - 1 }
>> +	};
>
>const?
>

Yes. I will modify in next respin.

Thanks,
Gavin
