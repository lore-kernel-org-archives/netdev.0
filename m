From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Thu, 28 Aug 2008 18:49:19 -0300
Message-ID: <20080828184919.611dd578@tux>
References: <20080819213417.45133573@tux>
 <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux>
 <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux>
 <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
 <20080824163843.33b4f890@tux>
 <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
 <20080826141812.589848a0@tux>
 <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:26070 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754923AbYH1Vta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 17:49:30 -0400
Received: by an-out-0708.google.com with SMTP id d40so101511and.103
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2008 14:49:28 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Aug 2008 23:40:58 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> while [ : ]; do
> 	date "+%s.%N"
> 	cat /proc/net/{netstat,snmp,tcp}
> 	sleep 1
> done

	Ok; Let's try again, now with more data (I hope):

	1) tcpdump (just port 995):

http://www.abusar.org/stall/dump-client
http://www.abusar.org/stall/dump-server

http://www.abusar.org/stall/dump-server-loopback

	I don't know if loopback is useful, just in case...

	2) the above script :

http://www.abusar.org/stall/script-client-log.txt
http://www.abusar.org/stall/script-server-log.txt

	3) and strace from the client Claws Mail:

http://www.abusar.org/stall/strace-client-claws-mail.txt

	I forgot to use the -r option in strace. But when Claws-mail
stalls, it gives the following multiple times:

read(4, 0xf48704, 4096)                 =3D -1 EAGAIN (Resource tempora=
rily unavailable)
select(5, [4], [4], NULL, NULL)         =3D 1 (out [4])
writev(4, [{"xxxxxxxxxxxxxxx"..., 108}], 1) =3D 108
select(5, [4], [], NULL, NULL)          =3D 1 (in [4])
read(4, "xxxxxxxxxxxxxxxxxxxxxx"..., 4096) =3D 108

	Well, I hope this time you have more information and I hope I didn't f=
orget anything.=20
If not, let's keep trying.

	Important: these data were collected with frto disabled (0) and htb di=
sabled too. So
it isn't related to frto, neither htb.

	Thank you!

--=20
