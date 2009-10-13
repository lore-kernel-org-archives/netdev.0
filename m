From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH 2/3] sky2: Reading registers in reset causes a hang
Date: Wed, 14 Oct 2009 08:08:44 +0900
Message-ID: <4AD5087C.3050305@ring3k.org>
References: <4AD337ED.4090409@ring3k.org>	<20091012091459.49eb1188@nehalam>	<392fb48f0910121536x3e7c37fbjd83ef821b3617644@mail.gmail.com> <20091013090038.6ec27475@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:38862 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753002AbZJMXKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 19:10:13 -0400
Received: by pzk26 with SMTP id 26so9424277pzk.4
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2009 16:09:36 -0700 (PDT)
In-Reply-To: <20091013090038.6ec27475@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 13 Oct 2009 07:36:45 +0900
> Mike McCormack <mikem@ring3k.org> wrote:
> 
>> 2009/10/13 Stephen Hemminger <shemminger@linux-foundation.org>
>>> On Mon, 12 Oct 2009 23:06:37 +0900
>>> Mike McCormack <mikem@ring3k.org> wrote:
>>>
>>>> When sky2 hardware is in reset, reading registers with ethtool -d
>>>> causes a hard system hang. eg.
>>>>
>>>>     ifconfig eth1 down
>>>>     ethtool -d eth1
>>>>
>>>> Avoid reading FIFOs, descriptor and status unit, etc. after we've
>>>>  bought the interface down, as these seem to cause the issue.
>>>>
>>>> Assume the same is true for the second port, as my port only has
>>>>  one card.
>>> I don't see this on my cards. Let me investigate further before
>>> committing this. Also, the debugfs interface would also be screwed
>>> if the registers were unavailable.
>> I forgot to include one other piece of information... I'm running a
>> ping -f at the sky2 interface on a remote machine. I'll check debugfs
>> tonight.
>>
> 
> You are flooding a down interface??

I'm flooding the interface from before it goes down. (Another machine ran
ping -f 192.168.0.100 continuously while I was testing this...)

/sys/kernel/debug/sky2/eth1 no longer exists after ifconfig eth1 down,
so debugfs cannot cause this problem on my machine.

It may be possible to fix this with extra cleanup in sky2_down, however I'm
not really which part of the chip needs more resetting...

thanks,

Mike
