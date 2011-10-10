From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: loopback IP alias breaks tftp?
Date: Mon, 10 Oct 2011 11:10:59 -0400
Message-ID: <20111010151058.GD1165@zod.bos.redhat.com>
References: <20111005202723.GE2479@zod.bos.redhat.com>
 <alpine.LFD.2.00.1110060009020.1959@ja.ssi.bg>
 <20111006132353.GF2479@zod.bos.redhat.com>
 <CAA6X_dP_LDO0hQYpixi-DtsKVJZQEgAY5wa4y_wYpEqXVyn7TQ@mail.gmail.com>
 <1317972573.3457.55.camel@edumazet-laptop>
 <20111007114017.GA1165@zod.bos.redhat.com>
 <1317989073.3207.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1317990201.3207.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joel Sing <jsing@google.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org, francis.souyri@apec.fr
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756Ab1JJPLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 11:11:17 -0400
Content-Disposition: inline
In-Reply-To: <1317990201.3207.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 07, 2011 at 02:23:21PM +0200, Eric Dumazet wrote:
> Le vendredi 07 octobre 2011 =E0 14:04 +0200, Eric Dumazet a =E9crit :
>=20
> > Its a completely different problem IMHO : You describe a tftp serve=
r
> > bug.
> >=20
> > Say your tftp server is multihomed with 3 different IPS :=20
> >=20
> > 192.168.20.21, 192.168.20.22, 192.168.20.23
> >=20
> > And tftp server listens to any address (UDP port 69) : 0.0.0.0:69
> >=20
> > When receiving a request on 192.168.20.22, it should use same sourc=
e
> > address, not let the system chose a "random or whatever policy" one=
=2E
> >=20
> >=20
> >=20
> > So I would suggest to check/fix if TFTP server uses the correct soc=
ket
> > API to get both the client IP and its own IP in each UDP datagram
> >=20
> > -> setsockopt(fd, IPPROTO_IP, &on, sizeof(on))
>=20
> > This permits tftp server to use the same "struct in_pktinfo" for re=
plies, forcing a correct source address.
> >=20
>=20
> By the way, there is no need for tftp change :
>=20
> Just launch several tftpd instances, and bind each them to one
> particular IP.
>=20
> If started from xinetd.d :
>=20
> $ cat /etc/xinetd.d/tftp1
> service tftp
> {
> 	socket_type		=3D dgram
> 	protocol		=3D udp
> 	wait			=3D yes
> 	user			=3D root
> 	server			=3D /usr/sbin/in.tftpd
> 	server_args		=3D -s /tftpboot
> 	disable			=3D no
> 	bind		=3D 192.168.20.21
> 	per_source		=3D 11
> 	cps			=3D 100 2
> 	flags			=3D IPv4
> }

(I've CC'd the original bug reporter now.)

I did this locally and it still timed out.  So the bind alone is not
enough to fix the problem.  At least not on lo:0 127.0.0.2.

Changing the source address in the routing table as Joel suggested does
work around the problem.

So, in summary,  either the TFTP server needs to be changed per your
original suggestion, or the routing table needs to be altered for every
alias?  Is that correct?

josh
