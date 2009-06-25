From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] tcp: race in receive part
Date: Thu, 25 Jun 2009 12:46:43 +0200
Message-ID: <4A435593.1050806@cosmosbay.com>
References: <20090618102727.GC3782@jolsa.lab.eng.brq.redhat.com> <4A3A49F2.6060705@gmail.com> <20090623091257.GA4850@jolsa.lab.eng.brq.redhat.com> <4A40AF2A.3050509@gmail.com> <20090624102038.GA5409@jolsa.lab.eng.brq.redhat.com> <4A42082D.9060402@gmail.com> <20090624162112.GB5409@jolsa.lab.eng.brq.redhat.com> <4A435162.90109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	oleg@redhat.com
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57467 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760268AbZFYKrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 06:47:13 -0400
In-Reply-To: <4A435162.90109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
> Jiri Olsa a =C3=A9crit :
>> I made the modification, plz check the attached diff.
>>
>> I found some places where the read_lock is not ahead of the check:
>>   "if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))"
>>
>> I'm not sure we dont want to address those as well; located in follo=
wing
>> files:
>>         drivers/net/tun.c
>>         net/core/stream.c
>>         net/sctp/socket.c
>>         net/sunrpc/svcsock.c
>=20
> We'll take care of them later :)
>=20
>>
>> thanks,
>> jirka
>>
>=20
> This patch is OK with me, please submit a new formal patch with
> fresh ChangeLog so that we can all agree and Signed-off-by/Acked-by
>=20
> Oleg, I think your comment can be addressed in a followup patch ?
>=20
> Thanks to all

To clarify, I meant the second comment from Oleg.

Jiri, please define a "smp_mb__after_lock()" instead of smp_mb__after_r=
ead_lock()

+/* The {read|write|spin}_lock() on x86 are full memory barriers. */
+#define smp_mb__after_lock() do { } while (0)
+
