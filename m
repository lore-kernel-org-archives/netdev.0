From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/1] net: bcmgenet: fix incorrect return value checks
Date: Mon, 24 Apr 2017 12:52:09 -0700
Message-ID: <dc7e4db5-9bcf-1216-7f6e-aef20b4bba53@gmail.com>
References: <1492941665-17155-1-git-send-email-bianpan201602@163.com>
 <20170424.154806.387657447648095027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bianpan2016@163.com
To: David Miller <davem@davemloft.net>, bianpan201602@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33330 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S977147AbdDXTwR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 15:52:17 -0400
In-Reply-To: <20170424.154806.387657447648095027.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2017 12:48 PM, David Miller wrote:
> From: Pan Bian <bianpan201602@163.com>
> Date: Sun, 23 Apr 2017 18:01:05 +0800
> 
>> From: Pan Bian <bianpan2016@163.com>
>>
>> Function platform_get_irq() will return a negative value on errors.
>> However, in function bcmgenet_probe(), 0 is considered as a flag of
>> error. This patch fixes the bug by checking whether the return value of
>> platform_get_irq() is less than 0.
>>
>> Signed-off-by: Pan Bian <bianpan2016@163.com>
> 
> I'm definitely not confident enough to apply this.
> 
> On some platform zero IRQs are invalid.
> 
> There are also lots of pieces of code that check the return value ">
> 0" as success.
> 

I don't think we are fixing any real issue by applying this patch, but I
will do a check on ARM, ARM64 and MIPS where this driver is used to see
if it is even remotely possible to have a 0 IRQ.
-- 
Florian
