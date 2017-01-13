From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 13/13] s390/qeth: remove OSN-devices
Date: Fri, 13 Jan 2017 12:55:28 +0100
Message-ID: <3e706715-0b5f-8011-3a2d-e1f66a37661f@linux.vnet.ibm.com>
References: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
 <20170111115600.4524-14-ubraun@linux.vnet.ibm.com>
 <20170111.090502.567203023670760362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52774 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751555AbdAMLze (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 06:55:34 -0500
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0DBs0Q5115819
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 06:55:33 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27xwuk1bbx-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 06:55:33 -0500
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 13 Jan 2017 11:55:31 -0000
In-Reply-To: <20170111.090502.567203023670760362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 01/11/2017 03:05 PM, David Miller wrote:
> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Date: Wed, 11 Jan 2017 12:56:00 +0100
> 
>> CHPID type "OSN" is a device type which had been used by IBM product
>> "Communication Controller for Linux". This product has reached end of
>> service in March 2016. Thus OSN support can be removed from the qeth
>> driver.
>>
>> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
>> Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
>> Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
> 
> IBM can certainly decide what physical products it wants to support
> or not, but this doesn't directly apply to what the Linux kernel
> driver supports.
> 
> We do not unilaterally remove support for a chip from a driver just
> because the vendor decides to stop supporting that chip.  In fact this
> is one of the main benefits and value-adds of Linux.
> 
> I'm not applying a patch series that removes support for a chipset
> for this reason, sorry.
> 
Dave, 

I am not sure, if the stopped chip support of vendors is something
equivalent to the removal of OSN-CHPID support for s390. Probably
I used misleading terms like "OSN-device" in my patch description:

The standard networking card on s390 is called
"Open Systems Adapter-Express card" (shortly "OSA-card"), and for sure
the qeth driver continues to support it in general. Besides covering
traditional Ethernet traffic, an OSA-card can also be used for very
IBM-specific purposes.
The mode an OSA-card is running is configured outside of Linux in
the mainframe hardware configuration. Linux supports a subset of
these modes with the qeth and lcs drivers.

One very specific OSA-mode is the OSN-mode. This mode is one building
block for a Linux-assisted approach that allows
existing IBM mainframe operating systems to continue to run
IBM Systems Network Architecture (SNA) protocol programs.
Just these SNA related code parts in qeth would be removed with
this patch.

Do you still think it is important to keep code just needed for
IBM SNA traffic in the kernel?
Token Ring support for instance has been removed in 2012. Isn't this
something comparable to my intended removal of OSN-mode support in qeth?

In other words: Would it make sense to resend my patch with a better
description?

Kind regards, Ursula
