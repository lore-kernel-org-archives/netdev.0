From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Choppy TCP send performance
Date: Fri, 28 May 2010 23:16:17 +0200
Message-ID: <1275081377.2472.13.camel@edumazet-laptop>
References: <AANLkTilSrX5PifVHlxMjTK-wo_viD8IS_1m1k-vPOlE3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Tim Heath <theath@greenplum.com>
To: Ivan Novick <novickivan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:41420 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022Ab0E1VQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 17:16:22 -0400
Received: by wwb28 with SMTP id 28so67586wwb.19
        for <netdev@vger.kernel.org>; Fri, 28 May 2010 14:16:21 -0700 (PDT)
In-Reply-To: <AANLkTilSrX5PifVHlxMjTK-wo_viD8IS_1m1k-vPOlE3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 28 mai 2010 =C3=A0 13:38 -0700, Ivan Novick a =C3=A9crit :
> Hello,
>=20
> I am using RHEL5 and have 1 Gigabit NIC cards.
>=20
> When doing a loop sending 128 KB blocks of data using TCP.  I am usin=
g
> system tap to debug the performance and finding that:
>=20
> 90% of the send calls take about 100 micro seconds and 10% of the sen=
d
> calls take about 10 miliseconds.  The average send time is about 1
> milisecond
>=20
> The 10% of the calls taking about 10 milliseconds seem to be
> correlated with "sk_stream_wait_memory" calls in the kernel.
>=20
> sk_stream_wait_memory seems to be called when the send buffer is full
> and the next send call does not complete until the send buffer
> utilization goes down from 4,194,304 bytes to 2,814,968 bytes.
>=20
> This implies that the send that blocks on a full send buffer will not
> complete until there is 1 meg of free space in the send buffer even
> though the send could be accepted into the OS with only 128KB of free
> space.
>=20
> Do you think I am misinterpreting this data or is there a way to even
> out the send calls so that they they are more even in duration: appro=
x
> 1 milisecond per call.  Is there a parameter to reduce how much space
> needs to be free in the send buffer before a blocking send call can
> complete from user space?

static void sock_def_write_space(struct sock *sk)
{
=2E..
if ((atomic_read(&sk->sk_wmem_alloc) << 1) <=3D sk->sk_sndbuf) {
=2E..


Quick answer is : No, this is not tunable ( independantly than SNDBUF )

SO_SNDLOWAT is not implemented on linux, yet (its value is : 1).


Why would you want to wakeup your thread more than necessary ?



