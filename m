From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 1/1] net/smc: add SMC rendezvous protocol
Date: Thu, 12 Oct 2017 12:48:04 +0200
Message-ID: <b37b38df-cbb8-ca86-d460-9d3ec7acc2c6@linux.vnet.ibm.com>
References: <20171010141419.88190-1-ubraun@linux.vnet.ibm.com>
 <20171011.140652.272274136617199385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        hwippel@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:34760 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752620AbdJLKsL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 06:48:11 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9CAiDWL140448
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 06:48:11 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dj3byjgmy-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 06:48:11 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Oct 2017 11:48:08 +0100
In-Reply-To: <20171011.140652.272274136617199385.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 10/11/2017 11:06 PM, David Miller wrote:
> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Date: Tue, 10 Oct 2017 16:14:19 +0200
> 
>> The goal of this patch is to leave common TCP code unmodified. Thus,
>> it uses netfilter hooks to intercept TCP SYN and SYN/ACK
>> packets. For outgoing packets originating from SMC sockets, the
>> experimental option is added. For inbound packets destined for SMC
>> sockets, the experimental option is checked.
> 
> I think this really isn't going to pass.
> 
> It's a user experience nightmare when the kernel inserts and
> deletes filtering rules outside of what the user configures
> on their system.
> 
> This approach was also considerd for ipv6 ILA, and the same
> pushback was given.
> 
> Why not add support for these new options as a normal TCP
> socket option based feature?  Then normal userspace as well
> as the SMC stack can make use of it.
> 

Do you mean a solution like

https://www.mail-archive.com/netdev@vger.kernel.org/msg71321.html
https://www.mail-archive.com/netdev@vger.kernel.org/msg71324.html

with a new smc_rendezvous TCP socket option as trigger?
