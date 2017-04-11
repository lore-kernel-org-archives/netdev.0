From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 5/7] s390/qeth: improve endianness handling
Date: Tue, 11 Apr 2017 12:20:28 +0200
Message-ID: <aa0d0b73-ea21-743c-d2ce-451920eabd0c@linux.vnet.ibm.com>
References: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
 <20170405084015.35772-6-ubraun@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFC85F3@AcuExch.aculab.com>
 <8056aa76-8e2d-805e-1037-927714e9bfab@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFCAB25@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
        "jwi@linux.vnet.ibm.com" <jwi@linux.vnet.ibm.com>,
        "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>,
        "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
        "raspl@linux.vnet.ibm.com" <raspl@linux.vnet.ibm.com>,
        Hans Wippel <hwippel@linux.vnet.ibm.com>
To: David Laight <David.Laight@ACULAB.COM>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:38259 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752676AbdDKKUf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 06:20:35 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3BAJ3c9109892
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 06:20:35 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29rn4yur1v-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 06:20:34 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Tue, 11 Apr 2017 11:20:32 +0100
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFCAB25@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/10/2017 05:22 PM, David Laight wrote:
> From: Ursula Braun
>> Sent: 07 April 2017 13:33
>> On 04/07/2017 01:25 PM, David Laight wrote:
>>> From: Ursula Braun
>>>> Sent: 05 April 2017 09:40
>>>> From: Hans Wippel <hwippel@linux.vnet.ibm.com>
>>>>
>>>> Avoid endianness warnings reported by sparse by (1) using endianness
>>>> conversions for assigning and using network packet fields, and (2)
>>>> removing unnecessary endianness conversions from qeth_l3_rebuild_skb. No
>>>> functional changes.
>>>>
>>>> Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
>>>> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
>>>> ---
>>>>  drivers/s390/net/qeth_core.h      |  4 ++--
>>>>  drivers/s390/net/qeth_core_main.c | 11 +++++-----
>>>>  drivers/s390/net/qeth_l3_main.c   | 46 +++++++++++++++++++--------------------
>>>>  drivers/s390/net/qeth_l3_sys.c    |  4 ++--
>>>>  4 files changed, 33 insertions(+), 32 deletions(-)
>>>>
>>>> diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
>>>> index 22aa2cd..6764ab9 100644
>>>> --- a/drivers/s390/net/qeth_core.h
>>>> +++ b/drivers/s390/net/qeth_core.h
>>>> @@ -844,9 +844,9 @@ static inline int qeth_get_ip_version(struct sk_buff *skb)
>>>>  {
>>>>  	__be16 *p = &((struct ethhdr *)skb->data)->h_proto;
>>>>
>>>> -	if (*p == ETH_P_8021Q)
>>>> +	if (be16_to_cpu(*p) == ETH_P_8021Q)
>>>>  		p += 2;
>>>> -	switch (*p) {
>>>> +	switch (be16_to_cpu(*p)) {
>>>>  	case ETH_P_IPV6:
>>>
>>> These are definitely 'functional changes' on LE systems.
>> s390 is Big Endian; thus the change is basicly a NOP.
> 
>> The only purpose of this kind of patches is getting rid
>> of sparse warnings with our code.
> 
> Then say so in the commit message....
Understood, in future we will try to improve our commit message.
> 
> What you are really doing is fixing the code in case anyone tries
> to use it on a LE system.
> 
> 	David
> 
