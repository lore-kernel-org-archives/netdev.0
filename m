From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Splice status
Date: Tue, 6 Jul 2010 10:01:39 +0800
Message-ID: <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
	<AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
	<EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
	<1278334254.2877.158.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jens Axboe <axboe@kernel.dk>, Ofer Heifetz <oferh@marvell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35541 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082Ab0GFCCB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:02:01 -0400
Received: by vws5 with SMTP id 5so6816331vws.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 19:02:00 -0700 (PDT)
In-Reply-To: <1278334254.2877.158.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 5, 2010 at 8:50 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le lundi 05 juillet 2010 =E0 13:52 +0300, Ofer Heifetz a =E9crit :
>> I am using Samba, so from my understanding of the source code, it
> loops and performs splice(sock, pipe) and splice(pipe, fd). There is =
no
> flush of any sort in between.
>>
>> When you say drain you mean to flush all data to pipe?
>>
>
> Draining pipe before splice() call would only trigger the bug less
> often.

If we don't drain the pipe before calling splice(2), the data spliced
from pipe maybe not be what we expect. Then data corruption occurs.

>
> splice(sock, pipe) can block if caller dont use appropriate "non
> blocking pipe' splice() mode, even if pipe is empty before a splice()
> call.

I don't think it is expected. The code of sys_recvfile is much like
the sendfile(2) implementation in kernel. If sys_recvfile may block
without non_block flag, sendfile(2) may block too.

BTW: Samba can use sendfile(2) instead in sys_recvfile.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
