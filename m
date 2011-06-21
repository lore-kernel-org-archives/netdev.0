From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH]: Add Network Sysrq Support
Date: Tue, 21 Jun 2011 18:12:30 -0400
Message-ID: <4E01174E.2010403@redhat.com>
References: <20110621130040.12035.62533.sendpatchset@prarit.bos.redhat.com> <20110621130929.ddd107f7.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, agospoda@redhat.com,
	nhorman@redhat.com, lwoodman@redhat.com
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752255Ab1FUWMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 18:12:33 -0400
In-Reply-To: <20110621130929.ddd107f7.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/21/2011 04:09 PM, Randy Dunlap wrote:
>
>
>> +remote sysrq.
>> +
>> +To use this do:
>> +
>> +mount -t debugfs none /sys/kernel/debug/
>> +echo 1 > /proc/sys/kernel/sysrq
>> +echo <hex digit val> > /sys/kernel/debug/network_sysrq_magic
>> +echo 1 > /sys/kernel/debug/network_sysrq_enable
>>     
> so all of this (insecure) stuff has to be done before you suspect that
> you need it .. in case the local keyboard/console is dead.
>
>   

Randy,

Yes -- this needs to be enabled before the system is unresponsive.  I've
used it to sysrq-c systems that were reproducibly hanging in ways that
the system could not be accessed via console or keyboard.  It really is
a debug feature.

[I've also sysrq-t'd and sysrq-m'd systems as well fwiw]

>> +
>> +Then on another system you can do:
>> +
>> +ping -c 1 -p <hex digit val><hex val of sysrq> <target_system_name>
>>     
> What are the <up to 30 hex digits> for?
>
>   

A secret key.  By turning this on you're leaving a system susceptible to
a panic by anyone else who decides to ping your system.  The ping
payload accepts up to a 32 digit hex number.  Two of those are needed
for the sysrq type, so that leaves 30.

I figured a 30 digit hash, with multiple enabling steps, and single-shot
mode, was good enough to alleviate any security issues anyone would have
about this code.

I'll take all of your suggestions into [v2].

Thanks for the review,

P.
