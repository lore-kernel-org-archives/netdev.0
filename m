From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Fri, 11 Apr 2008 11:50:33 +0400
Message-ID: <47FF1849.1040600@openvz.org>
References: <47FEADCB.7070104@rtr.ca>	<20080410.172648.187059862.davem@davemloft.net>	<47FEB0E3.8080507@rtr.ca> <20080411.115907.116626245.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml@rtr.ca, davem@davemloft.net, jesper.juhl@gmail.com,
	tilman@imap.cc, jeff@garzik.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758410AbYDKH1N@vger.kernel.org>
In-Reply-To: <20080411.115907.116626245.yoshfuji@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <47FEB0E3.8080507@rtr.ca> (at Thu, 10 Apr 2008 20:29:23 -0=
400), Mark Lord <lkml@rtr.ca> says:
>=20
>> David Miller wrote:
>>> From: Mark Lord <lkml@rtr.ca>
>>> Date: Thu, 10 Apr 2008 20:16:11 -0400
>>>
>>>> [c67499c0e772064b37ad75eb69b28fc218752636 is first bad commit
>>>> commit c67499c0e772064b37ad75eb69b28fc218752636
>>>> Author: Pavel Emelyanov <xemul@openvz.org>
>>>> Date:   Thu Jan 31 05:06:40 2008 -0800
>>>>
>>>>     [NETNS]: Tcp-v4 sockets per-net lookup.
>>>>
>>>>     Add a net argument to inet_lookup and propagate it further
>>>>     into lookup calls. Plus tune the __inet_check_established.
>>>>
>>>>     The dccp and inet_diag, which use that lookup functions
>>>>     pass the init_net into them.
>>>>
>>>>     Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>>>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>>> Thanks Mark.
>>>
>>> Pavel can you take a look?  I suspect that the namespace
>>> changes or gets NULL'd out somehow and this leads to the
>>> resets because the socket can no longer be found.  Perhaps
>>> it's even a problem with time-wait socket namespace
>>> propagation.
>> ..
>>
>> My system here is now set up for quick/easy retest, if you have any
>> suggestions or patches to try out.
>=20
> Please try this, from net-2.6.26 tree.
>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Too late, but still
Acked-by: Pavel Emelyanov <xemul@openvz.org>

Sorry, guys, but my timezone does not allow me to react in time
to found bugs :( So, when I wake up in the morning I usually just
find out that someone has caught a BUG made by me and someone=20
else has fixed it already...

> ----
>>From 8d9f1744cab50acb0c6c9553be533621e01f178b Mon Sep 17 00:00:00 200=
1
> From: Daniel Lezcano <dlezcano@fr.ibm.com>
> Date: Fri, 21 Mar 2008 04:12:54 -0700
> Subject: [PATCH] [NETNS][IPV6] tcp - assign the netns for timewait so=
ckets
>=20
> Copy the network namespace from the socket to the timewait socket.
>=20
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/inet_timewait_sock.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_s=
ock.c
> index 876169f..717c411 100644
> --- a/net/ipv4/inet_timewait_sock.c
> +++ b/net/ipv4/inet_timewait_sock.c
> @@ -124,6 +124,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const =
struct sock *sk, const int stat
>  		tw->tw_hash	    =3D sk->sk_hash;
>  		tw->tw_ipv6only	    =3D 0;
>  		tw->tw_prot	    =3D sk->sk_prot_creator;
> +		tw->tw_net          =3D sk->sk_net;
>  		atomic_set(&tw->tw_refcnt, 1);
>  		inet_twsk_dead_node_init(tw);
>  		__module_get(tw->tw_prot->owner);
