From: "Frank Groeneveld" <frankgroeneveld@gmail.com>
Subject: Re: Kernel 2.6.28 regression: Hang after hibernate (patch included)
Date: Sun, 4 Jan 2009 21:44:04 +0100
Message-ID: <a00b9da20901041244h7a2146a3l93df6c9935613cae@mail.gmail.com>
References: <a00b9da20812281234u76da2ef5tb715f4c409eaf37c@mail.gmail.com>
	 <a00b9da20901020910i2625073av96ce68ec0c313a8c@mail.gmail.com>
	 <a00b9da20901021118h3e698d04q33fa9e87519e4d42@mail.gmail.com>
	 <200901022318.45675.rjw@sisk.pl>
	 <20090104192502.GA6196@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, "Pavel Machek" <pavel@suse.cz>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:60195 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbZADUoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 15:44:09 -0500
In-Reply-To: <20090104192502.GA6196@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/1/4 Francois Romieu <romieu@fr.zoreil.com>:
> Rafael J. Wysocki <rjw@sisk.pl> :
> [...]
>> Please don't top post, it makes following the discussion really difficult.
>>
>> On Friday 02 January 2009, Frank Groeneveld wrote:
>> > A kernel without SMP doesn't solve the problem. It gives the same
>> > output as before, except without the CPU notices. I also found out
>> > that a "vanilla" 2.6.27 does have the same problem. A patched 2.6.27
>> > kernel (by Gentoo Linux) doesn't have this problem. I attached that
>> > patch, so you might see what the problem is now.
>>
>> Not really, the patch (reproduced below for reference) is quite big and does
>> a couple of different things.  Also, it should be shown to the maintainer of
>> the code in question.
>
> Thanks for the Cc Rafael.
>
> The aforementioned patch matches three commits - mostly bugfixes - which
> went in between 2.6.27 and 2.6.28:
>
> commit ccdffb9a88b2907b159538d7bfd6256621db4f84
>
>    r8169: get ethtool settings through the generic mii helper
>
> commit 2857ffb7b8913ef713533ac5783abd70a20529e4
>
>    r8169: additional 8101 and 8102 support
>
> commit 523a609496dbc3897e530db2a2f27650d125ea00
>
>    r8169: fix RxMissed register access
>
> Frank, can you:
> 1. try the r8169.c file from the 2.6.28 tree with Ubuntu's kernel
> 2. grep for the XID line printed by the r8169 driver in the lernel's dmesg
>
> If 1. does not work , you can peel the onion with the patchkit available
> at http://userweb.kernel.org/~romieu/r8169/2.6.27/ : apply them in
> increasing order to your working Ubuntu driver until is stops waking
> up correctly (skip patches #0001, #0006 and #0007 as they match the
> commits above) or try a binary search.
>
> As a side note for those who remember the early 2.6.27-rc "null mac
> address with the r8169 driver", the patchkit does not include the
> patches which were included between 2.6.27 and 2.6.28 then later
> reverted.
>
> --
> Ueimor
>

Thanks for you reply. The XID in my kernel is:
eth0: RTL8168c/8111c at 0xf8836000, 00:30:1b:bd:da:08, XID 3c4000c0 IRQ 222
This is from an Ubuntu kernel, which has the driver as a module, but I
don't think that matters for this XID?
I'll try 1. tomorrow.

Regards,
Frank
