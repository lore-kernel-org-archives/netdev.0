From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH v3] add the driver for Analog Devices
	Blackfin on-chip CAN controllers
Date: Thu, 10 Dec 2009 05:45:52 -0500
Message-ID: <8bd0f97a0912100245k9930c90ke4b184da68a9f958@mail.gmail.com>
References: <1260430072-21106-1-git-send-email-21cnbao@gmail.com>
	<4B20BB36.50509@grandegger.com> <8bd0f97a0912100204gd2b09f6r2799d9f951d6b9e1@mail.gmail.com>
	<4B20CB82.6060702@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Barry Song <21cnbao@gmail.com>, socketcan-core@lists.berlios.de,
	uclinux-dist-devel@blackfin.uclinux.org, davem@davemloft.net,
	"H.J. Oertel" <oe@port.de>, netdev@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:44965 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933726AbZLJKqF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 05:46:05 -0500
Received: by ywh6 with SMTP id 6so6976532ywh.4
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 02:46:12 -0800 (PST)
In-Reply-To: <4B20CB82.6060702@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2009 at 05:20, Wolfgang Grandegger wrote:
> Mike Frysinger wrote:
>> On Thu, Dec 10, 2009 at 04:11, Wolfgang Grandegger wrote:
>>> Barry Song wrote:
>>>> +#include <linux/module.h>
>>>> +#include <linux/init.h>
>>>> +#include <linux/kernel.h>
>>>> +#include <linux/types.h>
>>> I think you don't need "types.h" as the code no longer uses "uint*_=
t".
>>
>> linux/types.h declares all types, like u* which this driver still us=
es
>
> I just remember that "linux/types.h" needs to be added for the uint*_=
t
> types. At a first glance I do not see __u8/u8 being defined in that
> header file but I might have missed something.

you need to follow the include paths

>>> Well, I'm still not a friend of the following inline functions,
>>> especially the *one-liners* which are called just *once*. With the =
usage
>>> of structs they seem even more useless.
>>
>> seems like it would make more sense to not even use the read/write
>> functions either. =C2=A0just declare the regs as volatile and assign=
/read
>> the struct directly.
>
> Two times no. Don't use volatile and proper accessor functions. See:
>
> http://lxr.linux.no/#linux+v2.6.32/Documentation/volatile-considered-=
harmful.txt

too bad the document is largely irrelevant (all but one paragraph)
because this is how volatiles were designed in the first place --
hardware I/O registers.  the CAN implementation here is Blackfin
specific and not going to be use elsewhere, so other architectures are
irrelevant.  the resulting C code would certainly look a hell of a lot
more natural without the useless I/O accessor functions, and be much
tighter.

at any rate, the common Blackfin I/O accessor functions force a lot of
useless overhead when used here as they're designed for async memory,
not MMRs.  the driver needs to be switched to the bfin_read/bfin_write
MMR functions.
-mike
