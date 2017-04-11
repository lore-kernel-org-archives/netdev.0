From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next V2 5/7] s390/qeth: improve endianness handling
Date: Tue, 11 Apr 2017 12:28:50 +0200
Message-ID: <509925af-3664-b9ff-7ae7-c668428b77cc@linux.vnet.ibm.com>
References: <20170407071538.63253-1-ubraun@linux.vnet.ibm.com>
 <20170407071538.63253-6-ubraun@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFFCAAFB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
        "jwi@linux.vnet.ibm.com" <jwi@linux.vnet.ibm.com>,
        "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>,
        "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
        "raspl@linux.vnet.ibm.com" <raspl@linux.vnet.ibm.com>
To: David Laight <David.Laight@ACULAB.COM>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:37772 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753995AbdDKK25 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 06:28:57 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3BASegL088064
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 06:28:56 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29rf05tde4-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 06:28:56 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Tue, 11 Apr 2017 11:28:53 +0100
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFCAAFB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/10/2017 05:16 PM, David Laight wrote:
> From: Ursula Braun
>> Sent: 07 April 2017 08:16
>> Avoid endianness warnings reported by sparse by (1) using endianness
>> conversions for assigning and using network packet fields, and (2)
>> removing unnecessary endianness conversions from qeth_l3_rebuild_skb. No
>> functional changes.
> ...
>> -	if (*p == ETH_P_8021Q)
>> +	if (be16_to_cpu(*p) == ETH_P_8021Q)
> ...
> 
> This is clearly different on little-endian systems.
> Also (probably) better written as:
> 
> 	if (*p == cpu_to_be16(ETH_P_8021Q))
> 
> so that the constant can by byteswapped.
> 
> 	David
> 

Thanks, we will keep that in mind for future patches.

> 
> 
