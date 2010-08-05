From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch] isdn: fix information leak
Date: Thu, 5 Aug 2010 19:02:06 +0800
Message-ID: <AANLkTi=8ThVqTHpQmDfoon02C-VZ0JwBRtSrU7dzvvNt@mail.gmail.com>
References: <20100805093806.GF9031@bicker> <AANLkTin4jtYuaxYfxDAgST857sD2K4Q28mPcPW=xd-V3@mail.gmail.com>
	<20100805101938.GH9031@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35553 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755581Ab0HELC1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 07:02:27 -0400
In-Reply-To: <20100805101938.GH9031@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 5, 2010 at 6:19 PM, Dan Carpenter <error27@gmail.com> wrote=
:
> On Thu, Aug 05, 2010 at 06:08:08PM +0800, Changli Gao wrote:
>> On Thu, Aug 5, 2010 at 5:38 PM, Dan Carpenter <error27@gmail.com> wr=
ote:
>> > The main motivation of this patch changing strcpy() to strlcpy().
>> > We strcpy() to copy a 48 byte buffers into a 49 byte buffers. =A0S=
o at
>> > best the last byte has leaked information, or maybe there is an
>> > overflow? =A0Anyway, this patch closes the information leaks by ze=
roing
>> > the memory and the calls to strlcpy() prevent overflows.
>>
>> strlcpy() can handle the terminator NUL. so you don't need to zero i=
t.
>
> If there are no NUL chars in "rcvmsg->msg_data.byte_array" then strlc=
py()
> is sufficient, but if there is a NUL character then you need to zero =
the
> memory. =A0The patch handles both possibilities.
>

the second parameter of strlcpy() must a NUL terminated C string. I
think you means strncpy().

=46YI:
http://lxr.linux.no/#linux+v2.6.35/lib/string.c#L146
http://lxr.linux.no/#linux+v2.6.35/lib/string.c#L119


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
