From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.32.8-stable review : kernel crashed asap
Date: Sat, 6 Feb 2010 12:19:26 +0800
Message-ID: <20100206041926.GA4529@hack>
References: <201002042129.41462.toralf.foerster@gmx.de> <201002051622.02980.toralf.foerster@gmx.de> <20100205155701.GC9690@hack> <201002051730.39578.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f185.google.com ([209.85.223.185]:53148 "EHLO
	mail-iw0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867Ab0BFEZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 23:25:16 -0500
Content-Disposition: inline
In-Reply-To: <201002051730.39578.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 05, 2010 at 05:30:39PM +0100, Toralf F=C3=B6rster wrote:
>
>Am=C3=A9rico Wang wrote at 16:57:01
>> On Fri, Feb 05, 2010 at 04:22:02PM +0100, Toralf F=C3=B6rster wrote:
>> >Am=C3=A9rico Wang wrote at 16:10:21
>> >
>> >> On Thu, Feb 04, 2010 at 09:29:41PM +0100, Toralf F=C3=B6rster wro=
te:
>> >> >Immediately during boot it crashed w/ the attached config - no l=
ines
>> >> > within syslog  to post.
>> >>
>> >> What error messages did you see on your screen?
>> >
>> >I attached a screen shot.
>>=20
>> Thanks! It's better that if you can capture these info via netconsol=
e
>> or something like that, so that you copy and paste them into email.
>I know - but I'm at home where I've only this ThinkPad ...
>
>> Hmm, it seems that a null pointer deref happened in
>> net/ipv4/devinet.c::inetdev_init(), so Cc'ing netdev guys....
>>=20
>> Could you please run the command:
>>=20
>>   addr2line -e your_2.6.32.8_vmlinux 0xc11fea28
>>=20
>> to check in which line we dereferenced a null pointer?
>
>Here's the information :
>
>n22 /usr/src/linux-2.6.32.8 # addr2line -e vmlinux 0xc11fea28
>devinet.c:0
>

Hmm, thanks, we already found the problem, I think the patch here:

http://patchwork.kernel.org/patch/77357/

should be able to fix this problem.

Thanks for reporting!

--=20
Live like a child, think like the god.
=20
