From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: i.Mx6Quad - eth0: tx queue full!
Date: Wed, 30 Jan 2013 14:04:36 -0700
Message-ID: <51098AE4.5030305@boundarydevices.com>
References: <5106B7EE.3040603@gmail.com> <5106D5D4.2090200@boundarydevices.com> <5107FA00.2010809@gmail.com> <51081910.4030707@boundarydevices.com> <51093882.2060700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LAK <linux-arm-kernel@lists.infradead.org>,
	Fabio Estevam <festevam@gmail.com>
To: Vikram Narayanan <vikram186@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:63483 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400Ab3A3VEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 16:04:39 -0500
Received: by mail-pa0-f54.google.com with SMTP id bi5so1306864pad.27
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 13:04:39 -0800 (PST)
In-Reply-To: <51093882.2060700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/2013 8:13 AM, Vikram Narayanan wrote:
> On 1/30/2013 12:16 AM, Troy Kisky wrote:
>> I have fixed this bug (and more) on Freescale's kernel
>> (imx-3.0.35_1.1.0). I created a branch you can try.
>> Feel free to port to mainline.
> Thanks a lot for the branch. I saw a lot of differences between
> your driver and the mainline. I should spend some time If I had
> to port this to mainline.
>   
>> This is the patch that should fix your problem
>> fec: clear TX_FULL in fec_restart
>>
>>
>> Please let me know results.
> When NAPI is disabled I saw a severe packet loss
> (around 40% in a flood ping) which spitted out this,
>
> [  470.390928] net eth0: missed rxf 2000000 1c000000 0
> [  470.419098] net eth0: missed rxf 2000000 1c000000 0
> [  470.443800] net eth0: missed rxf 2000000 1c000000 0
> [  470.450315] net eth0: missed rxf 2000000 1c000000 0
>
> When NAPI is enabled, it was working good. Though it
> resulted in the same error, it recovered by itself,
> which is perfectly fine for me. :)
>

You'll also have better performance if you pass "enable_wait_mode=off" 
in bootargs.
