From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Thu, 28 Jul 2005 23:24:33 +0200
Message-ID: <42E94D11.4090002@cosmosbay.com>
References: <42E8FF24.9070009@cosmosbay.com>	<20050728.123922.126777020.davem@davemloft.net>	<42E94680.8060309@cosmosbay.com> <20050728.135826.63129319.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050728.135826.63129319.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 28 Jul 2005 22:56:32 +0200
>=20
>=20
>>But in case of DDOS, prefetches are a win.
>=20
>=20
> Numbers please, I'm simply curious.
>=20
>=20

I have no profiling info for this exact patch, I'm sorry David.

On a dual opteron machine, this thing from ip_route_input() is very expen=
sive :

  RT_CACHE_STAT_INC(in_hlist_search);

ip_route_input() use a total of 3.4563 % of one cpu, but this 'increment'=
 takes 1.20 % !!!

0.0047   mov    2123529(%rip),%rax        # ffffffff804b4a60 <rt_cache_st=
at>
1.1898   not    %rax
          mov    %gs:0x34,%edx
0.0042   movslq %edx,%rdx
          mov    (%rax,%rdx,8),%rax
          incl   0x38(%rax)

Sometime I wonder if oprofile can be trusted :(

Maybe we should increment a counter on the stack and do a final
    if (counter !=3D 0)
        RT_CACHE_STAT_ADD(in_hlist_search, counter);

Eric
