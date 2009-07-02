From: Andres Freund <andres@anarazel.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (possibly caused
    by netem)
Date: Thu, 02 Jul 2009 02:37:24 +0200
Message-ID: <4A4C0144.5070203@anarazel.de>
References: <4A4A9DD6.8060800@anarazel.de> <4A4BAD5F.7050908@gmail.com> <4A4BD384.3090407@anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.anarazel.de ([217.115.131.40]:55043 "EHLO smtp.anarazel.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565AbZGBAhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2009 20:37:24 -0400
In-Reply-To: <4A4BD384.3090407@anarazel.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2009 11:22 PM, Andres Freund wrote:
> On 07/01/2009 08:39 PM, Jarek Poplawski wrote:
>> Andres Freund wrote, On 07/01/2009 01:20 AM:
>>> While playing around with netem (time, not packet count based loss-
>>> bursts) I experienced soft lockups several times - to exclude it was my
>>> modifications causing this I recompiled with the original and it is
>>> still locking up.
>>> I captured several of those traces via the thankfully
>>> still working netconsole.
>>> The simplest policy I could reproduce the error with was:
>>> tc qdisc add dev eth0 root handle 1: netem delay 10ms loss 0
>>>
>>> I could not reproduce the error without delay - but that may only be a
>>> timing issue, as the host I was mainly transferring data to was on a
>>> local network.
>>> I could not reproduce the issue on lo.
>>>
>>> The time to reproduce the error varied from seconds after executing tc
>>> to several minutes.
>>>
>>> Traces 5+6 are made with vanilla
>>> 52989765629e7d182b4f146050ebba0abf2cb0b7
>>>
>>> The earlier traces are made with parts of my patches applied, and only
>>> included for completeness as I don't believe my modifications were
>>> causing this and all traces are different, so it may give some clues.
>>>
>>> Lockdep was enabled but did not diagnose anything relevant (one dvb
>>> warning during bootup).
>>>
>>> Any ideas for debugging?
>>
>> Maybe these traces will be enough, but lockdep report could save time.
>> If dvb warning triggers every time then lockdep probably turns off
>> just after (it works this way, unless something was changed). So,
>> could you try to repeat this without dvb? Btw., did you try this on
>> some earlier kernel?
> Yes. Today I could not manage to reproduce it on 2.6.30 but could on
> current git...
> Will try without dvb.
So I tried - and I did not catch any lockdep output before the crash. 
Unfortunately I do not have another machine on the same local network to 
catch any messages after the crash... So I could be missing some warning 
(I did synchronous logging though).
Will check with netconsole tomorrow.

Andres
