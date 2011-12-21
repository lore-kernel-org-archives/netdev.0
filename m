From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: [PATCH] Avoid extra calculation in ip_route_input_common
Date: Wed, 21 Dec 2011 14:04:33 +0800
Message-ID: <4EF176F1.1080802@linux.vnet.ibm.com>
References: <4EF16AA3.2070303@linux.vnet.ibm.com> <20111221.005758.556186611596801704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:35808 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928Ab1LUGEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 01:04:39 -0500
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Wed, 21 Dec 2011 06:01:46 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pBL64ZYp4845582
	for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 17:04:35 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pBL64Yfb009389
	for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 17:04:35 +1100
In-Reply-To: <20111221.005758.556186611596801704.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2011 01:57 PM, David Miller wrote:

> From: Michael Wang <wangyun@linux.vnet.ibm.com>
> Date: Wed, 21 Dec 2011 13:12:03 +0800
> 
>> From: Michael Wang <wangyun@linux.vnet.ibm.com>
>>
>> If previous condition doesn't meet, the later check will be cancelled.
>> So we don't need to do all the calculation.
>>
>> Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
> 
> This is intentional to reduce the number of branch prediction
> misses, please don't change this.
> 
> Once we read one of these values, the rest are incredibly cheap,
> the real cost is if we have tons of real branches here, each
> of which can be mispredicted.
> 

Hi, David

Thanks for your detailed explain, now I know the reason we use this style :)

Thanks,
Michael Wang
