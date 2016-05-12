From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH -next 3/4] net: w5100: increase TX timeout period
Date: Thu, 12 May 2016 19:50:39 +0900
Message-ID: <CAC5umyguwoKbOeNUjx_BH0=Aj5WdJoQan0p6LJppObsSw3Wd1g@mail.gmail.com>
References: <1462948227-21276-1-git-send-email-akinobu.mita@gmail.com>
 <1462948227-21276-4-git-send-email-akinobu.mita@gmail.com> <20160511.194901.2167534565947789386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Mike Sinkovsky <msink@permonline.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:36153 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbcELKvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 06:51:00 -0400
Received: by mail-qg0-f67.google.com with SMTP id f74so4899791qge.3
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 03:50:59 -0700 (PDT)
In-Reply-To: <20160511.194901.2167534565947789386.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-05-12 8:49 GMT+09:00 David Miller <davem@davemloft.net>:
> From: Akinobu Mita <akinobu.mita@gmail.com>
> Date: Wed, 11 May 2016 15:30:26 +0900
>
>> This increases TX timeout period from one second to 5 seconds which is
>> default value defined in net/sched/sch_generic.c.
>>
>> The one second timeout is too short for W5100 with SPI interface mode
>> which doesn't support burst READ/WRITE processing in the SPI transfer.
>> If the packet is transmitted while RX packets are being received at a
>> very high rate, the TX transmittion work in the workqueue is delayed
>> and the watchdog timer is expired.
>>
>> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
>
> It would be just cleaner to just remove the assignment completely, and
> let said net/sched/sch_generic.c code set the default for you.

Sounds good.  I'll resubmit the series with that change.
