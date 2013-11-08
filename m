From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [patch] net: make ndev->irq signed for error handling
Date: Fri, 8 Nov 2013 14:48:49 +0530
Message-ID: <527CAC79.3030709@ti.com>
References: <20131107074849.GF21844@elgon.mountain> <527B842E.2060909@ti.com> <20131107122249.GN20521@mwanda> <527BC0CF.70003@ti.com> <20131108084136.GY26669@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:47071 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460Ab3KHJSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 04:18:55 -0500
In-Reply-To: <20131108084136.GY26669@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 08 November 2013 02:11 PM, Dan Carpenter wrote:
> On Thu, Nov 07, 2013 at 10:03:19PM +0530, Mugunthan V N wrote:
>> On Thursday 07 November 2013 05:52 PM, Dan Carpenter wrote:
>>> On Thu, Nov 07, 2013 at 05:44:38PM +0530, Mugunthan V N wrote:
>>>> On Thursday 07 November 2013 01:18 PM, Dan Carpenter wrote:
>>>>> There is a bug in cpsw_probe() where we do:
>>>>>
>>>>> 	ndev->irq = platform_get_irq(pdev, 0);
>>>>> 	if (ndev->irq < 0) {
>>>>>
>>>>> The problem is that "ndev->irq" is unsigned so the error handling
>>>>> doesn't work.  I have changed it to a regular int.
>>>>>
>>>>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>>> ndev->irq is never used any where in the driver, I think its better to
>>>> remove this part of code from probe. If every one is ok, I can send a
>>>> patch to remove the code.
>>> It seems like cpsw_ndo_poll_controller() uses it.
>>>
>>>
>> That can be changed to pass one of the interrupt numbers from priv as
>> the irq number is not used in interrupt service routine.
> I don't know anything about this driver, so I'm fine with your idea.
>
Anyhow David has applied your patch, I will send a driver cleanup patch
seperately.

Regards
Mugunthan V N
