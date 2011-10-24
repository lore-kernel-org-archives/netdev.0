From: Luciano Ruete <lruete@sequre.com.ar>
Subject: Re: Kernel Panic every 2 weeks on ISP server (NULL pointer dereference)
Date: Mon, 24 Oct 2011 15:09:13 -0300
Message-ID: <201110241509.14027.lruete@sequre.com.ar>
References: <201110222218.12524.lruete@sequre.com.ar> <1319346989.6180.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.vita.com.ar ([190.15.202.242]:55799 "HELO vita.com.ar"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751108Ab1JXSJT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 14:09:19 -0400
In-Reply-To: <1319346989.6180.71.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, October 23, 2011 02:16:29 am Eric Dumazet wrote:
> Le samedi 22 octobre 2011 =C3=A0 22:18 -0300, Luciano Ruete a =C3=A9c=
rit :
> > Hi,
> >=20
> > I'm the sysadmin at a 3500 customers ISP, wich runs an iptables+tc
> > solution for load balancing and QoS.
> >=20
> > Every 2 or 3 weeks the server panics with a "NULL pointer dereferen=
ce"
> > and with IP at "dev_queue_xmit"
> >=20
> > It is curious that if i disable MSI on the network card driver this
> > panics seems to disapear, does this ring a bell?
> >=20
> > The server is an IBM, previously with Broadcom NetXtreme II BCM5709=
 nics
> > and now with Intel 82576. I change the nics thinking that maybe the=
 bug
> > was in Broadcom Driver but it seems to affect MSI in general.
> >=20
> > The tc+iptables rules are auto-generated with sequreisp[1] an ISP
> > solution that i wrote and is open sourced under AGPLv3.
> >=20
> > Tell me if you need any further information, and plz CC because I'm=
 not
> > suscribed.
> >=20
> >=20
> > root@server:~# uname -a
> > Linux server 2.6.35-30-server #60~lucid1-Ubuntu SMP Tue Sep 20 22:2=
8:40
> > UTC 2011 x86_64 GNU/Linux
> >=20
> >=20
> > [1]https://github.com/sequre/sequreisp
>=20
> Hi Luciano

Hi Eric!

Thanks for your answer...

>=20
> [694250.472081] Code: f6
> 49 c1 e6 07          shl    $0x7,%r14
> 66 89 93 ac 00 00 00 mov    %dx,0xac(%rbx)
>[...]
> This looks like a dev_pick_tx() bug, using an out of bound
> queue_index number and returning a txq pointing after
> the device allocated array.

Clear explanation, is there a tool to map the trace to kernel code, or =
you did=20
this by hand?=20

> With recent kernels, this cannot happen anymore because
> we added fixes in this area.
>=20
> You could try Ubuntu 11.10 (based on linux 3.0) kernel
> on your server, or apply following patch :
>=20
> commit df32cc193ad88f7b1326b90af799c927b27f7654
> Author: Tom Herbert <therbert@google.com>
> Date:   Mon Nov 1 12:55:52 2010 -0700
>=20
>     net: check queue_index from sock is valid for device
>=20
>     In dev_pick_tx recompute the queue index if the value stored in t=
he
>     socket is greater than or equal to the number of real queues for =
the
>     device.  The saved index in the sock structure is not guaranteed =
to
>     be appropriate for the egress device (this could happen on a rout=
e
>     change or in presence of tunnelling).  The result of the queue in=
dex
>     being bad would be to return a bogus queue (crash could prersumab=
ly
>     follow).

Lot of ruote changes in this server, there are 30 upstream providers(15=
 are=20
dynamic IP ADSLs) load balanced using VLANs and a VLAN switch.

Thanks again i will try the kernel upgrade and post results in this thr=
ead.

Regards!
--=20
Luciano Ruete
Sequre - Sys Admin
Mitre 617, piso 7, of. 1=20
+54 261 4254894
Mendoza - Argentina
http://www.sequreisp.com/
http://www.sequre.com.ar/
