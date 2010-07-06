From: Ofer Heifetz <oferh@marvell.com>
Subject: RE: Splice status
Date: Tue, 6 Jul 2010 05:36:16 +0300
Message-ID: <EE71107DF0D1F24FA2D95041E64AB9E8ED250DB2F1@IL-MB01.marvell.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
 	<AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
 	<EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
 	<1278334254.2877.158.camel@edumazet-laptop>,<AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jens Axboe <axboe@kernel.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galiil.marvell.com ([199.203.130.254]:13960 "EHLO
	galiil.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756852Ab0GFCkD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:40:03 -0400
In-Reply-To: <AANLkTim_eBmT-6HmkqG5d7k0jjrGKAFBjzqVCricTpgK@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Regarding your remark of replacing sendfile with recvfile, I have two q=
uestions:
1) what will be used if both are enabled in smb.conf
2) from your experience, which is faster for reading files?
________________________________________
=46rom: Changli Gao [xiaosuo@gmail.com]
Sent: Tuesday, July 06, 2010 5:01 AM
To: Eric Dumazet
Cc: Jens Axboe; Ofer Heifetz; netdev@vger.kernel.org
Subject: Re: Splice status

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

--
Regards,
Changli Gao(xiaosuo@gmail.com)
