From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH RESEND net-next 13/15] smc: receive data from RMBE
Date: Fri, 2 Sep 2016 15:05:01 +0200
Message-ID: <7121effc-5f89-ac22-bbab-a8aedebae9fd@linux.vnet.ibm.com>
References: <1470737580-43012-14-git-send-email-ubraun@linux.vnet.ibm.com>
 <20160809.143245.2022037008405834176.davem@davemloft.net>
 <653f839a-8098-da62-3437-8b002d929a50@linux.vnet.ibm.com>
 <20160810.104556.1507709019319192063.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        utz.bacher@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:43321 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752737AbcIBNFO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 09:05:14 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u82D2xQq146752
        for <netdev@vger.kernel.org>; Fri, 2 Sep 2016 09:05:13 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 256cqe4ktc-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 09:05:09 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 2 Sep 2016 14:05:06 +0100
In-Reply-To: <20160810.104556.1507709019319192063.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

sorry for the late answer; I had to interrupt my SMC-R activities for a 
while; now I can continue ...

On 08/10/2016 07:45 PM, David Miller wrote:
> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Date: Wed, 10 Aug 2016 15:44:00 +0200
>
>> But there are still usages (and conn->rx_curs_confirmed is one of
>> them), where I need an 8-byte cursor field to be read and written
>> atomicaly, even though I do not care whether the write operation has
>> been beaten or not. But I do care that reading the cursor does not
>> return a partially updated cursor. Isn't xchg() a possible solution
>> in this case?
>
> Either the cpu supports 64-bit stores or it does not.
>
> xchg() and atomicity have absolutely nothing to do with this.
>

Understood, I wrongly used xchg() for atomicity. I now realize that I 
would need cursor locking for 32-bit architectures - something I would 
like to defer. Thus I would like to come up with V2 of SMC-R with builds 
restricted to 64-bit architectures only, and thus no usage of xchg() 
anymore.
