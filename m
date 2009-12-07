From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH] tcp: Fix for stalling connections
Date: Mon, 07 Dec 2009 12:17:46 +0100
Message-ID: <4B1CE45A.9010908@tvk.rwth-aachen.de>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de> <4B1C9D94.3070504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	=?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Frederic Leroy <fredo@starox.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:54438 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933682AbZLGLRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 06:17:43 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUA00CQV4PN6720@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Mon, 07 Dec 2009 12:17:47 +0100 (CET)
In-reply-to: <4B1C9D94.3070504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet schrieb:
> Damian Lukowski a =E9crit :
>> This patch fixes a problem in the TCP connection timeout calculation=
=2E
>> Currently, timeout decisions are made on the basis of the current
>> tcp_time_stamp and retrans_stamp, which is usually set at the first
>> retransmission.
>> However, if the retransmission fails in tcp_retransmit_skb(),
>> retrans_stamp is not updated and remains zero. This leads to wrong
>> decisions in retransmits_timed_out() if tcp_time_stamp is larger tha=
n
>> the specified timeout, which is very likely.
>> In this case, the TCP connection dies after the first attempted
>> (and unsuccessful) retransmission.
>>
>> With this patch, tcp_skb_cb->when is used instead, when retrans_stam=
p
>> is not available.
>>
>> Thanks to Ilpo J=E4rvinen for code suggestions.
>>
>> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
>=20
> Hmm, how old is this bug ?
>=20
> You should a hint of faulty commit so that stable team can apply
> this patch to 2.6.32 & 2.6.31
>=20
> git describe 6fa12c85031485dff38ce550c24f10da23b0adaa
>=20
> v2.6.31-rc5-1853-g6fa12c8

It has been introduced with retransmits_timed_out() in 2.6.32,
as timeout calculations have based on the number of
retransmissions before. The patch is needed for 2.6.32
and 2.6.33, but 2.6.31 does not use retransmits_timed_out().

> Or maybe David handles this for us, I dont know...
>=20
> Minor note : retransmits_timed_out() is used in from net/ipv4/tcp_tim=
er.c
> I wonder why its a "static inline" in include/net/tcp.h

I can place it in tcp_timer.c, if it's that, what you mean.

Regards.

> Thanks
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


