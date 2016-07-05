From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: WARNING: CPU: 0 PID: 0 at net/ipv4/af_inet.c:155
 inet_sock_destruct+0x1c4/0x1dc
Date: Tue, 5 Jul 2016 14:55:09 -0700
Message-ID: <577C2CBD.2060905@gmail.com>
References: <577BB72E.3020904@free.fr> <577BC94A.4060204@free.fr>
 <577BD201.2040202@gmail.com> <577BD8BB.7060306@free.fr>
 <577BDE4E.7090509@gmail.com> <577C17F5.4020106@free.fr>
 <577C2506.5030300@gmail.com> <577C2BF0.7030409@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Sebastian Frias <sf84@laposte.net>
To: Mason <slash.tmp@free.fr>, linux-pm <linux-pm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33352 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755398AbcGEVzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 17:55:13 -0400
In-Reply-To: <577C2BF0.7030409@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2016 02:51 PM, Mason wrote:
>>> Therefore, loss of context cannot possibly explain the
>>> warning I am seeing.
>>
>> No, but if you go all the way down to trying to suspend and the last
>> step is the firmware failing, anything you have suspended needs to be
>> unwinded, for your ethernet driver that means that you went through a
>> successful suspend then resume cycle even if it failed down later when
>> the platform attempted to suspend.
> 
> So it is the driver's responsibility to "shut down" on resume?

It is the driver responsibility to know how to suspend and resume a
device it manages, and it does that by implementing appropriate
suspend/resume callbacks.

> (I had the vague impression that the suspend framework would
> "disable" the device through the appropriate callback.)

The suspend framework knows which drivers implement suspend/resume and
calls them appropriately (based on parenting/bus hierarchy), but it
won't automatigally do anything because there is no such thing as magic
when it comes to suspending hardware, this needs to be a controlled
sequence.
-- 
Florian
