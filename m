From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2: eth0: hung mac 7:69 fifo 0 (165:176)
Date: Sun, 25 Nov 2007 13:25:06 -0800
Message-ID: <4749E832.1060800@linux-foundation.org>
References: <873av03c0f.fsf@burly.wgtn.ondioline.org> <E1Iw7Ig-0000zL-6Z@asgard.prans.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Collins <paul@burly.ondioline.org>, netdev@vger.kernel.org
To: Elvis Pranskevichus <el@prans.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58374 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753102AbXKYVZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2007 16:25:06 -0500
In-Reply-To: <E1Iw7Ig-0000zL-6Z@asgard.prans.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Elvis Pranskevichus wrote:
> Paul Collins wrote:
>
>   
>> Hi Stephen,
>>
>> Running amd64 kernel built from 2ffbb8377c7a0713baf6644e285adc27a5654582
>> after about three days of uptime, this morning I found the network dead
>> and the following in dmesg:
>>
>>   sky2 eth0: hung mac 7:69 fifo 0 (165:176)
>>   sky2 eth0: receiver hang detected
>>   sky2 eth0: disabling interface
>>   NETDEV WATCHDOG: eth0: transmit timed out
>>   sky2 eth0: tx timeout
>>   sky2 eth0: transmit ring 26 .. 26 report=26 done=26
>>   NETDEV WATCHDOG: eth0: transmit timed out
>>   sky2 eth0: tx timeout
>>   sky2 eth0: transmit ring 26 .. 26 report=26 done=26
>>
>> The watchdog had been blorping for about three hours when I discovered
>> it and rebooted the machine.
>>
>>     
>
> Hello,
>
> I have exactly the same problem with my 88E8053 on 2.6.24-rc3 here. While
> there have always been issues with sky2 on that particular board, now the
> situation is worse than ever. Netdev watchdog goes into an endless loop
> reporting timeouts and the whole machine goes down to the point that I'm
> forced to reset (not even SysRq works).
>
> Here's the snippet from the log:
>
> sky2 eth0: hung mac 123:3 fifo 194 (150:144)
> sky2 eth0: receiver hang detected
> sky2 eth0: disabling interface
> NETDEV WATCHDOG: eth0: transmit timed out
> sky2 eth0: tx timeout
> sky2 eth0: transmit ring 178 .. 188 report=178 done=178
> NETDEV WATCHDOG: eth0: transmit timed out
> sky2 eth0: tx timeout
> sky2 eth0: transmit ring 178 .. 188 report=178 done=178
> NETDEV WATCHDOG: eth0: transmit timed out
> sky2 eth0: tx timeout
> sky2 eth0: transmit ring 178 .. 188 report=178 done=178
> NETDEV WATCHDOG: eth0: transmit timed out
>
> The board is identical to Paul's.
>
> While mac hangs were common in 2.6.23 and earlier, it was possible to
> recover the interface (either automatically, or by manual rmmod/modprobe). 
> I can't reliably reproduce the issue, but it consistently comes up a couple
> of times a day during high network load.
>
> Any hints, patches are highly appreciated. 
>
> Thanks,
>   

Two important bits of data:

1) What is hardware (output of lspci and dmesg) would be useful to know 
which type
of board is involved.

2) Is this a regression, or always the case.  Does 2.6.23 work okay?

The problems with FIFO in the past, have been limited to Yukon-EC 
without flow control.
The hardware has bugs where if the FIFO gets exactly filled it hangs. 
Flow control avoids
the problem.

