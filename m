From: Patrick McHardy <kaber@trash.net>
Subject: Re: sk->sk_socket seems to disappear before connection termination
Date: Thu, 11 Nov 2010 12:00:32 +0100
Message-ID: <4CDBCCD0.9040807@trash.net>
References: <alpine.LNX.2.01.1011100205220.17978@obet.zrqbmnf.qr>	 <1289368037.2700.14.camel@edumazet-laptop>	 <alpine.LNX.2.01.1011101148060.18018@obet.zrqbmnf.qr>	 <1289407451.2860.239.camel@edumazet-laptop>	 <alpine.LNX.2.01.1011101816330.2886@obet.zrqbmnf.qr> <1289410679.2860.245.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	David Howells <dhowells@redhat.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	=?UTF-8?B?UmFmYcWCIE1hag==?= <rafal.maj.it@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36144 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270Ab0KKLAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 06:00:35 -0500
In-Reply-To: <1289410679.2860.245.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10.11.2010 18:37, Eric Dumazet wrote:
> Le mercredi 10 novembre 2010 =C3=A0 18:17 +0100, Jan Engelhardt a =C3=
=A9crit :
>> On Wednesday 2010-11-10 17:44, Eric Dumazet wrote:
>>>
>>> [ 9920.234680] ipt_LOG: sk=3Dffff880118bd32c0 sk->sk_socket=3Dffff8=
8011d0d8c00 file=3Dffff88011cd4e100
>>> [ 9920.234731] IN=3D OUT=3Deth1 SRC=3D192.168.20.108 DST=3D192.168.=
20.110 LEN=3D52 TOS=3D0x10 PREC=3D0x00 TTL=3D64 ID=3D63704 DF PROTO=3DT=
CP SPT=3D60088 DPT=3D22 WINDOW=3D35 RES=3D0x00 ACK FIN URGP=3D0 UID=3D0=
 GID=3D0=20
>>> [ 9920.235221] ipt_LOG: sk=3Dffff880078998000 sk->sk_socket=3Dffff8=
80078c58300 file=3D          (null)
>>> [ 9920.235271] IN=3D OUT=3Deth1 SRC=3D192.168.20.108 DST=3D192.168.=
20.110 LEN=3D52 TOS=3D0x00 PREC=3D0x00 TTL=3D64 ID=3D0 DF PROTO=3DTCP S=
PT=3D60088 DPT=3D22 WINDOW=3D35 RES=3D0x00 ACK URGP=3D0=20
>>>
>>> You can see in my log, that the last packet seems to be from a diff=
erent
>>> socket ! (sk pointer changed to ffff880078998000 !)
>>
>> Yes, that's it.
>>
>>> Well well well, thats an ACK, in answer to FIN packet received from=
 remote
>>> side.
>>
>> But why is it not handled by sk ffff880118bd32c0 anymore?
>> It does have, after all, the same (addr,port) tuple.
>> And it is sort of a hiccup for xt_owner users.
>=20
> Its because of TIMEWAIT state : no more socket
>=20
> We use a special tcp socket (net->ipv4.tcp_sock) in tcp_v4_send_ack()

Yeah, this has always been a problem with the owner match.
I don't think this fixable, it should probably only be used
in a stateful manner.
