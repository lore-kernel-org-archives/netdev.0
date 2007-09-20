From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2.6.23-rc6 Resending] NETWORKING : Edge Triggered EPOLLOUT
 events get missed for TCP sockets
Date: Thu, 20 Sep 2007 08:11:48 +0200
Message-ID: <46F20F24.1020900@cosmosbay.com>
References: <331107.71046.qm@web53704.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Davide Libenzi <davidel@xmailserver.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Nagendra Tomar <tomer_iisc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:37355 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbXITGL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 02:11:57 -0400
In-Reply-To: <331107.71046.qm@web53704.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nagendra Tomar a =E9crit :
> --- Davide Libenzi <davidel@xmailserver.org> wrote:
>=20
>> On Wed, 19 Sep 2007, David Miller wrote:
>>
>>> From: Nagendra Tomar <tomer_iisc@yahoo.com>
>>> Date: Wed, 19 Sep 2007 15:37:09 -0700 (PDT)
>>>
>>>> With the SOCK_NOSPACE check in tcp_check_space(), this epoll_wait =
call will=20
>>>> not return, even when the incoming acks free the buffers.
>>>>         Note that this patch assumes that the SOCK_NOSPACE check i=
n
>>>> tcp_check_space is a trivial optimization which can be safely remo=
ved.
>>> I already replied to your patch posting explaining that whatever is
>>> not setting SOCK_NOSPACE should be fixed instead.
>>>
>>> Please address that, thanks.
>> You're not planning of putting the notion of a SOCK_NOSPACE bit insi=
de a=20
>> completely device-unaware interface like epoll, I hope?
>>
>=20
> Definitely not !=20
>=20
> The point is that the "tcp write space available"=20
> wakeup does not get called if SOCK_NOSPACE bit is not set. This was
> fine when the wakeup was merely a wakeup (since SOCK_NOSPACE bit=20
> indicated that someone really cared abt the wakeup). Now after the
> introduction of callback'ed wakeups, we might have some work to
> do inside the callback even if there is nobody interested in the wake=
up
> at that point of time.=20
>=20
> In this particular case the ep_poll_callback is not getting called an=
d
> hence the socket fd is not getting added to the ready list.
>=20

Does it means that with your patch each ACK on a ET managed socket will=
=20
trigger an epoll event   ?

Maybe your very sensitive high throuput appication needs to set a flag =
or=20
something at socket level to ask for such a behavior.

The default should stay as is. That is an event should be sent only if =
someone=20
cared about the wakeup.

