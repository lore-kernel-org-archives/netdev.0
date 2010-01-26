From: Michael <michael@moffatt.org.nz>
Subject: Re: [Bugme-new] [Bug 15091] New: starfire causes kernel BUG when
 interface goes up
Date: Tue, 26 Jan 2010 14:44:31 +1300
Message-ID: <4B5E48FF.2050406@moffatt.org.nz>
References: <bug-15091-10286@http.bugzilla.kernel.org/>
 <20100125170816.db9435ed.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.clear.net.nz ([203.97.37.64]:46970 "EHLO
	smtp4.clear.net.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab0AZCAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 21:00:05 -0500
Received: from zurvan.moffatt.org.nz
 (203-79-69-250.cable.telstraclear.net [203.79.69.250])
 by smtp4.clear.net.nz (CLEAR Net Mail)
 with ESMTP id <0KWT00318ZI93R40@smtp4.clear.net.nz> for
 netdev@vger.kernel.org; Tue, 26 Jan 2010 14:44:34 +1300 (NZDT)
In-reply-to: <20100125170816.db9435ed.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

I believe that this is a regression, yes.

I will attempt to compile up some kernels this week and provide more 
info. Should I start at 26 and go up or at 31 and go down?

I can't use anything lower than 26 according to udev. I was running 24 
but compiled 32 when I upgraded udev.

Regards,
Michael.

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Wed, 20 Jan 2010 04:29:20 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>   
>> http://bugzilla.kernel.org/show_bug.cgi?id=15091
>>
>>            Summary: starfire causes kernel BUG when interface goes up
>>            Product: Drivers
>>            Version: 2.5
>>     Kernel Version: 2.6.32
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Network
>>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>>         ReportedBy: michael@moffatt.org.nz
>>         Regression: No
>>
>>
>> Created an attachment (id=24651)
>>  --> (http://bugzilla.kernel.org/attachment.cgi?id=24651)
>> ls -l /dev (before crash)
>>
>> I formerly used 2.6.20 and 2.6.24 with a couple of starfire 4 port ethernet
>> cards. On 2.6.32 the interfaces don't start on boot and when I issue "ifconfig
>> ethX up" (where X is a starfire port).
>>
>> Sometimes the exception causes the whole kernel to freeze. Sometimes the kernel
>> keeps going. On the occasion that the kernel kept going I was able to retrieve
>> syslog, which has the full kernel information.
>>
>> Note that in syslog, you can see that I inserted a USB memory stick in order to
>> copy off the attached files. The kernel oops happens without the USB memory
>> stick inserted.
>>
>> I can reproduce this at will. At the moment I simply can't use my two four port
>> starfire network cards.
>>
>> This PC is a root-over-NFS system.
>>
>>     
>
> Starfire is triggering the BUG_ON(!test_bit(NAPI_STATE_SCHED,
> &n->state)); in napi_enable().
>
> This is a regression somewhere between 2.6.24 and 2.6.32(!).
>
>
>   

