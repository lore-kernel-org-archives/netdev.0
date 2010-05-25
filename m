From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Warning in net/ipv4/af_inet.c:154
Date: Tue, 25 May 2010 17:27:09 +0200
Message-ID: <1274801229.5020.80.camel@edumazet-laptop>
References: <20100525115813.GA28063@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43758 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800Ab0EYPb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 11:31:56 -0400
Received: by bwz7 with SMTP id 7so1326376bwz.19
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 08:31:54 -0700 (PDT)
In-Reply-To: <20100525115813.GA28063@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 25 mai 2010 =C3=A0 21:58 +1000, Anton Blanchard a =C3=A9crit :
> Hi,
>=20
> A build from last night (2.6.34-git9) is hitting the following WARN_O=
N on
> a ppc64 box:
>=20
> Badness at net/ipv4/af_inet.c:154
>=20
> NIP [c00000000062b034] .inet_sock_destruct+0x1b0/0x1f0
> LR [c0000000005b376c] .__sk_free+0x58/0x154
> Call Trace:
> [c000000000088c0c] .__local_bh_disable+0xdc/0xfc (unreliable)
> [c0000000005b376c] .__sk_free+0x58/0x154
> [c0000000005b3978] .sk_free+0x4c/0x60
> [c0000000005b3ab4] .sk_common_release+0x128/0x148
> [c00000000061da44] .udp_lib_close+0x28/0x40
> [c00000000062a990] .inet_release+0xd0/0xf8
> [c0000000005adbf8] .sock_release+0x60/0xec
> [c0000000005adcd0] .sock_close+0x4c/0x6c
> [c000000000186554] .__fput+0x184/0x270
> [c00000000018668c] .fput+0x4c/0x60
> [c000000000182248] .filp_close+0xc8/0xf4
> [c0000000000826d4] .put_files_struct+0xc8/0x158
> [c0000000000827d4] .exit_files+0x70/0x8c
> [c0000000000848cc] .do_exit+0x2c8/0x82c
> [c000000000084efc] .do_group_exit+0xcc/0x100
> [c000000000084f5c] .SyS_exit_group+0x2c/0x48
> [c000000000008554] syscall_exit+0x0/0x40
>=20
> Which is:
>=20
>         WARN_ON(sk->sk_forward_alloc);
>=20

Yes, the infamous one :)

Is it reproductible ? What kind of workload is it ?
What is the NIC involved ?



