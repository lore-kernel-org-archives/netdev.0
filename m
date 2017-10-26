From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 1/3] ibmvnic: Enable scatter-gather support
Date: Thu, 26 Oct 2017 12:51:52 -0500
Message-ID: <e5015ac2-d0f7-ff95-eea5-1adbedb13dc9@linux.vnet.ibm.com>
References: <1508261816-3145-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <1508261816-3145-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD009AA16@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:57404 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932309AbdJZRv4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 13:51:56 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9QHglUq174973
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 13:51:56 -0400
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2duh22aw1w-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 13:51:56 -0400
Received: from localhost
        by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Thu, 26 Oct 2017 13:51:55 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD009AA16@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2017 06:04 AM, David Laight wrote:
> From: Thomas Falcon
>> Sent: 17 October 2017 18:37
>> This patch enables scatter gather support. Since there is no
>> HW/FW scatter-gather support at this time, the driver needs to
>> loop through each fragment and copy it to a contiguous, pre-mapped
>> buffer entry.
> ...
>>  	offset = index * adapter->req_mtu;
>>  	dst = tx_pool->long_term_buff.buff + offset;
> You should be able to treat the pre-allocated data area as a
> big ring buffer.
> So it can hold a lot of small frames or a few big ones.
> This slightly complicates the 'is there enough space for
> this packet' check since you need buffer space as well
> as a ring entry.
>
> You also really want to align each tx buffer on a 4n+2
> boundary so that most of the copy is aligned.

Thanks for your comments. I'll try to address that in a future patch.

>
>>  	memset(dst, 0, adapter->req_mtu);
> Seems unnecessary.

I removed that bit, and so far you seem to be right :) .

Thanks,
Tom
>
> 	David
>
