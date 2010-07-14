From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Wed, 14 Jul 2010 13:41:28 +0200
Message-ID: <4C3DA268.20008@trash.net>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>	 <AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>	 <1278626921.2435.73.camel@edumazet-laptop>	 <AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com> <1278695580.2696.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felipe W Damasio <felipewd@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278695580.2696.55.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09.07.2010 19:13, Eric Dumazet wrote:
> Le vendredi 09 juillet 2010 =E0 12:03 -0300, Felipe W Damasio a =E9cr=
it :
>> Hi,
>>
>> 2010/7/8 Eric Dumazet <eric.dumazet@gmail.com>:
>>> Please try to reproduce a new report.
>>>
>>> It looks like a memory corruption, and it would be good to see if a
>>> common pattern is occurring.
>>
>> I'm trying..the thing is the freeze occured on the machine that sits
>> on a 200Mbps ISP in bridge-mode. Since the machine frooze, and the
>> whole ISP went down for a few minutes, I'm not allowed to run any
>> tests on it.
>>
>> I've setup the same scenario on a lab, but since last night been
>> unable to reproduce the bug. Maybe there's a clue on the this crash
>> below that can help me write some program to trigger the problem?
>>
>=20
> Reviewing tproxy stuff I spotted a problem in nf_tproxy_assign_sock()
> but I could not see how it could explain your crash.
>=20
> We can read uninitialized memory and trigger a fault in
> nf_tproxy_assign_sock(), not later in tcp_recvmsg()...
>=20
> David, Patrick, what do you think ?
>=20
> Thanks
>=20
> [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
>=20
> transparent field of a socket is either inet_twsk(sk)->tw_transparent
> for timewait sockets, or inet_sk(sk)->transparent for other sockets
> (TCP/UDP).

I don't see anything preventing use of timewait sockets, so the
patch looks correct to me.

Applied to nf-2.6.git, thanks Eric.
