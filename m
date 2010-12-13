From: Shmulik Hen <shmulik@trego.co.il>
Subject: Re: System blocks (hangs) on ifconfig up
Date: Mon, 13 Dec 2010 15:11:25 +0200
Message-ID: <4D061B7D.9050805@trego.co.il>
References: <4D04E38A.1040605@trego.co.il>	 <1292194983.3136.294.camel@localhost>  <4D05E400.7080409@trego.co.il> <1292243832.2759.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shmulik Hen <shmulik.hen@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:51860 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757574Ab0LMNLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 08:11:31 -0500
Received: by bwz16 with SMTP id 16so6565405bwz.4
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 05:11:30 -0800 (PST)
In-Reply-To: <1292243832.2759.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2010 02:37 PM, Eric Dumazet wrote:
>>
>> But why does this happen only the second time I run ifconfig up?
>> How come the entire system is totally frozen?
>> I can't even switch to other applications running. If I run 'top' in another
>> console, it stops refreshing for the entire period.
>>
>> I'll try to explain better;
>> The driver I'm referring to is part of an embedded system development kit.
>> It runs on the controlling side, which may be a PC or some Linux embedded
>> system. It exposes a virtual interface that allows to communicate via
>> ethernet connection to a remote board, and performs the firmware download
>> to that board.
>> Unfortunately, the firmware download stage is  done during dev->open() of
>> this virtual interface. The call to wait_event_interruptible_timeout()
>> is there to make sure the boot process of the remote board is complete via a
>> message. If all goes well the first time, there is no delay, but if the
>> operation
>> fails for any reason the first time, and a second attempt is made (another
>> ifconfig up), we see the freezing.
>>
>> Since this driver is (mostly) closed source, I had to try and reproduce
>> the situation
>> in an all open-source driver - this is the sample code I attached to my
>> original
>> message. The call to mdelay() there is meant to simulate the delay of
>> the original
>> driver - it schedules.
>>
> mdelay() does a busy wait. If you are not SMP, this means a 'freeze'
>
> If you want to schedule, you should use msleep()

Correct - my bad. When I use msleep() in the sample code there is no freeze.

But I still don't get it - when using mdelay(), why does the system 
freeze only
the second time but not in the first time?
And what about wait_event_interruptible_timeout()? surely it doesn't
do a busy loop - I can see  the source calling schedule().

