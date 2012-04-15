From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: Documenting UNIX domain autobind
Date: Mon, 16 Apr 2012 09:07:39 +1200
Message-ID: <CAKgNAkjSDCkSkTOKyP=49cCFYSEChcfuYD8K6KJ5MVuWVpHJ5Q@mail.gmail.com>
References: <AANLkTimtTazMmDvQFgASsVGa=AYvPZqUaUmyg5p7VVY1@mail.gmail.com> <201010171428.DDC17187.FFFJSLtOOHOMQV@I-love.SAKURA.ne.jp>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, mzxreary@0pointer.de
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52193 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533Ab2DOVIA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 17:08:00 -0400
Received: by iagz16 with SMTP id z16so6570677iag.19
        for <netdev@vger.kernel.org>; Sun, 15 Apr 2012 14:07:59 -0700 (PDT)
In-Reply-To: <201010171428.DDC17187.FFFJSLtOOHOMQV@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Tetsuo Handa,

On Sun, Oct 17, 2010 at 6:28 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Michael Kerrisk wrote:
>> I think this text correctly documents the technical details (but let
>> me know if you see errors). What is lacking is an explanation of why
>> this feature exists. Is someone able to explain where this feature i=
s
>> used and why?
>
> What we can see is that unix_autobind() was added in Linux 2.1.15
>
> =A0http://lxr.linux.no/linux-old+v2.1.15/net/unix/af_unix.c#L464
> =A0addr->len =3D sprintf(addr->name->sun_path+1, "%08x", ordernum) + =
1 + sizeof(short);
>
> =A049 * Differences from 2.0.0-11-... (ANK)
> =A050 * =A0 =A0 =A0Bug fixes and improvements.
> =A051 * =A0 =A0 =A0 =A0 =A0 =A0 =A0- client shutdown killed server so=
cket.
> =A052 * =A0 =A0 =A0 =A0 =A0 =A0 =A0- removed all useless cli/sti pair=
s.
> =A053 * =A0 =A0 =A0 =A0 =A0 =A0 =A0- (suspicious!) not allow connect/=
send to connected not to us
> =A054 * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0socket, return EPERM.
> =A055 *
> =A056 * =A0 =A0 =A0Semantic changes/extensions.
> =A057 * =A0 =A0 =A0 =A0 =A0 =A0 =A0- generic control message passing.
> =A058 * =A0 =A0 =A0 =A0 =A0 =A0 =A0- SCM_CREDENTIALS control message.
> =A059 * =A0 =A0 =A0 =A0 =A0 =A0 =A0- "Abstract" (not FS based) socket=
 bindings.
> =A060 * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Abstract names are sequences o=
f bytes (not zero terminated)
> =A061 * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0started by 0, so that this nam=
e space does not intersect
> =A062 * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0with BSD names.
>
> and was changed to allow from 2^32 names to 2^20 names in Linux 2.3.1=
5.
>
> =A0http://lxr.linux.no/linux-old+v2.3.15/net/unix/af_unix.c#L514
> =A0addr->len =3D sprintf(addr->name->sun_path+1, "%05x", ordernum) + =
1 + sizeof(short);
>
> I don't know the reason.

Long after the fact, I added text to unix(7) to note the change in the
size of the namespace you noted above.

However, the unix(7) man page still lacks an explanation of the
purpose of the autobind feature. Can anyone help?

Thanks,

Michael



--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
