From: Upakul Barkakaty <upakul@gmail.com>
Subject: Re: mv643xx_eth: Delay required in reading the PHY registers.
Date: Wed, 6 May 2009 17:56:14 +0530
Message-ID: <bb58ac4d0905060526h1afff3co7adbaeebde7b7f4e@mail.gmail.com>
References: <bb58ac4d0905010108n77ca98c8t59409952150c3a11@mail.gmail.com>
	 <bb58ac4d0905052238m59ca2767i1e84d90b6abb46d4@mail.gmail.com>
	 <20090506121834.GA32010@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:46081 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbZEFM0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 08:26:14 -0400
Received: by yx-out-2324.google.com with SMTP id 3so32219yxj.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2009 05:26:14 -0700 (PDT)
In-Reply-To: <20090506121834.GA32010@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Lennert for the reply. Appreciate it.

On Wed, May 6, 2009 at 5:48 PM, Lennert Buytenhek
<buytenh@wantstofly.org> wrote:
> On Wed, May 06, 2009 at 11:08:07AM +0530, Upakul Barkakaty wrote:
>
>> I am using the Marvell ethernet driver[mv643xx_eth]. The function
>> eth_port_read_smi_reg(), uses a delay in order to wait for the SMI
>> register to become available.
>>
>> Does anyone have any clue how much time it actually takes for the SMI
>> register to become available? Actually I am using an older version of
>> the driver which does not use the udelay functions in the loops. It
>> rather has a "for" loop for putting a timeout. Now the gcc-4.3.1
>> compiler optimizes out the "for" loop. So I need to replace the "for"
>> loop with a delay function. Now the question is "how much delay would
>> be appropriate".
>>
>> Any replies in this regard would be appreciated.
>
> You sent me the same question in private mail -- I wonder how many
> other people you've sent this question to.
>
> As I told you in private mail as well, any recent version of the driver
> will wait for SMI completion by waiting for the appropriate interrupt.
> If you really cannot use that option, then even though the transaction
> is on the order of tens of microseconds, I would still try to go to
> sleep at least for a little bit (say, msleep(10)) as SMI accesses aren't
> in a critical path and not busy-waiting while sucking up CPU is more
> important than getting the access done as quick as you can.
>



-- 
Regards,
Upakul Barkakaty
