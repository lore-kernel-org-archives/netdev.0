From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (results with
 IRQ affinity)
Date: Mon, 20 Apr 2009 23:52:30 +0200
Message-ID: <49ECEE9E.7050307@cosmosbay.com>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net> <alpine.DEB.1.10.0904171238550.20049@qirst.com> <49EA2D7F.3080405@cosmosbay.com> <alpine.DEB.1.10.0904201305360.1585@qirst.com> <49ECB775.6030202@cosmosbay.com> <alpine.DEB.1.10.0904201410430.3361@qirst.com> <49ECC30A.9040501@cosmosbay.com> <alpine.DEB.1.10.0904201510410.17816@qirst.com> <49ECD5E4.60100@cosmosbay.com> <alpine.DEB.1.10.0904201712140.27942@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48034 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbZDTVxS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 17:53:18 -0400
In-Reply-To: <alpine.DEB.1.10.0904201712140.27942@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Mon, 20 Apr 2009, Eric Dumazet wrote:
>=20
>> No changes in udpping but noise.
>=20
> No changes in the results of udpping that you would not consider nois=
e?

Only changes where when every cpus played, so it really is not meaningf=
ull.

>=20
> The time syscalls are virtual syscalls which are quite cheap.

Not on 32bits afaik, with glibc I use at least, strace told me.

clock_gettime(CLOCK_REALTIME, {1240262824, 400770067}) =3D 0
sendto(3, "\314\335\356\377\300\250\24p#)\0\0\23\324\207\264\377\377\37=
7\377\0\1\2\3\4\5\6\7\10\t\0\0\3"..., 300, 0, {sa_family=3DAF_INET, sin=
_port=3Dhtons(9000), sin_addr=3Dinet_addr("192.168.20.112")}, 16) =3D 3=
00
recvfrom(3, "\314\335\356\377\300\250\24p#)\0\0\23\324\207\264\377\377\=
377\377\0\1\2\3\4\5\6\7\10\t\0\0\3"..., 300, 0, NULL, NULL) =3D 300
clock_gettime(CLOCK_REALTIME, {1240262824, 401108324}) =3D 0
clock_gettime(CLOCK_REALTIME, {1240262824, 401177464}) =3D 0

cost is about 384 ns on this 32bits 3GHz machine (without strace), whil=
e its 51 ns on 64 bit

Anyway I'll try to boot 64bit kernels on those 32bit distro machines in=
 following days...


