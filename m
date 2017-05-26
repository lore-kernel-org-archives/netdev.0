From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] ibmvnic: Enable TSO support
Date: Fri, 26 May 2017 11:11:05 -0500
Message-ID: <9ca1acdb-cc19-46d2-a0cf-1f2dc00678e6@linux.vnet.ibm.com>
References: <1495679366-7149-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <20170525.144626.1787511445330790842.davem@davemloft.net>
 <20170525.144935.732861960034229990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:44639 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932234AbdEZQLL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 12:11:11 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4QG8sUn124051
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 12:11:10 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2apc2ecdmm-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 12:11:10 -0400
Received: from localhost
        by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Fri, 26 May 2017 10:11:09 -0600
In-Reply-To: <20170525.144935.732861960034229990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/25/2017 01:49 PM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 25 May 2017 14:46:26 -0400 (EDT)
>
>> From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
>> Date: Wed, 24 May 2017 21:29:26 -0500
>>
>>> The feature is also enabled by a module parameter.
>>> This parameter is necessary because TSO can not easily be
>>> enabled or disabled in firmware without reinitializing the driver.
>> Sorry, this is unacceptable.  When I say no module parameters,
>> I really really mean it.
>>
>> Users should not be burdoned with having to know a special knob for
>> every driver in order to adjust what is a generic feature.
>>
>> You'll have to find another way to accomodate this.
> Also, TSO helps without SG only because you haven't implemented
> support for xmit_more in this driver to decrease the number of
> doorball updates and VM enters.
>
> I bet if you added xmit_more support, TSO wouldn't give you much
> if any performance boost if you have to linearize.
>
Thanks for the feedback. I'm looking into providing that support, but for the time being we would like to continue with supporting TSO, without using a module parameter this time.
