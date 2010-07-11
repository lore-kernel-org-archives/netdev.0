From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Splice status
Date: Sun, 11 Jul 2010 21:08:33 +0800
Message-ID: <AANLkTinRnDwMOS5NrmzKqYZpczG4nfHSvKA9Gw-_UUzO@mail.gmail.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
	<AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
	<EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
	<1278334254.2877.158.camel@edumazet-laptop> <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
	<1278388580.2466.305.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jens Axboe <axboe@kernel.dk>, Ofer Heifetz <oferh@marvell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60284 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720Ab0GKNIz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 09:08:55 -0400
Received: by vws5 with SMTP id 5so3408944vws.19
        for <netdev@vger.kernel.org>; Sun, 11 Jul 2010 06:08:54 -0700 (PDT)
In-Reply-To: <1278388580.2466.305.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 6, 2010 at 11:56 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 06 juillet 2010 =E0 10:01 +0800, Changli Gao a =E9crit :
>>
>> If we don't drain the pipe before calling splice(2), the data splice=
d
>> from pipe maybe not be what we expect. Then data corruption occurs.
>>
>
> This is not true. A pipe is a pipe is a buffer. You dont need it to b=
e
> empty when using it. Nowhere in documentation its stated.

Do you mean splice(2) empties the pipe buffer before using it as an
output buffer? If not, the pipe draining is needed to avoid data
corruption.

>
> However, a single skb can fill a pipe, even if "its empty"
>

Yea. Because tcp_splice_read() doesn't know if the __tcp_splice_read
returns due to pipe fulling.

>
>> >
>> > splice(sock, pipe) can block if caller dont use appropriate "non
>> > blocking pipe' splice() mode, even if pipe is empty before a splic=
e()
>> > call.
>>
>> I don't think it is expected. The code of sys_recvfile is much like
>> the sendfile(2) implementation in kernel. If sys_recvfile may block
>> without non_block flag, sendfile(2) may block too.
>
> Then it would be a bug. You might fix it easily.

It seems reasonable. I'll fix it.

>
> Using splice() correctly (ie, not blocking on sock->pipe) should work
> too.
>
> Again, you can block on splice(sock, pipe), iff you have a second thr=
ead
> doing the opposite (pipe->file) in parallel to unblock you. But samba
> recvfile algo is using a single thread.
>




--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
