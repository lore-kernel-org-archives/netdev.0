From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Fri, 9 Aug 2013 17:53:30 +0200
Message-ID: <CA+MoWDqsDWSD_q93UyiPNFzmgXGGfCPMH9VeQf1YmiO6OYuhwQ@mail.gmail.com>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>
	<20130808210918.GE5502@mwanda>
	<20130808.142054.1541424422807503741.davem@davemloft.net>
	<1375997625.2087.14.camel@joe-AO722>
	<520452F4.2070804@gmail.com>
	<1376015984.2087.31.camel@joe-AO722>
	<520457AD.9060508@gmail.com>
	<1376016864.2087.34.camel@joe-AO722>
	<52045B31.9000002@gmail.com>
	<1376018881.2087.48.camel@joe-AO722>
	<5204641C.3090905@gmail.com>
	<CA+MoWDrsHf4NFE_iszymh6SaBfXsMybC194ZQaKgURmCFwiJRQ@mail.gmail.com>
	<1376061267.2087.91.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Kumar Gaurav <kumargauravgupta3@gmail.com>,
	David Miller <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>, emilio@elopez.com.ar,
	mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:41593 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934068Ab3HIPxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 11:53:31 -0400
In-Reply-To: <1376061267.2087.91.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

On Fri, Aug 9, 2013 at 5:14 PM, Joe Perches <joe@perches.com> wrote:
> On Fri, 2013-08-09 at 15:15 +0200, Peter Senna Tschudin wrote:
>> Coccinelle (http://coccinelle.lip6.fr/) can help you in this task. The
>> semantic patch below takes care of both cases for you:
>
> Hi Peter & Kumar
>
> Coccinelle (aka: spatch) is a good/great way to do this.
>
> (btw Peter, your email was whitespace damaged)
Sorry for that, my fault. I've composed the E-mail using mutt, but
sent it using gmail web interface.

>
> Peter's useful conversion won't find/convert cases where
> IRQF_DISABLED is used in a #define like:
>
>> diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
>> []
>> @@ -915,7 +915,7 @@ static int ks_net_open(struct net_device *netdev)
>> []
>> -#define        KS_INT_FLAGS    (IRQF_DISABLED|IRQF_TRIGGER_LOW)
>> +#define        KS_INT_FLAGS    (IRQF_TRIGGER_LOW)

Coccinelle works with macros, the problem in this specific case, is
that the #define is inside a function, and due that it is ignored by
Coccinelle. If you move the #define to outside of the function or try
running spatch on ethernet/smsc/smc91x.h, you see the transformation
on the macro definition.

But, I would prefer to remove this define instead of patching it,
seems to make more sense to me.

Thanks!



-- 
Peter
