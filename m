From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Sat, 13 Sep 2008 20:31:17 -0300
Message-ID: <20080913203117.2a55ea2c@tux>
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
	<20080828184919.611dd578@tux>
	<Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
	<20080830035650.42be37d7@tux>
	<Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi>
	<20080907051718.58bf133d@tux>
	<Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi>
	<20080908172043.0d25a427@tux>
	<Pine.LNX.4.64.0809100942370.24708@wrl-59.cs.helsinki.fi>
	<20080911143006.2f516569@tux>
	<Pine.LNX.4.64.0809112140250.26799@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:25794 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbYIMXb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2008 19:31:28 -0400
Received: by yw-out-2324.google.com with SMTP id 9so470493ywe.1
        for <netdev@vger.kernel.org>; Sat, 13 Sep 2008 16:31:26 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0809112140250.26799@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Sep 2008 13:16:19 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Ok.

	Ilpo, except for DROP [INPUT] lines, does the log below means somethin=
g to you?

Sep 13 20:01:21 teleporto vmunix: DROP [INPUT]: IN=3Deth0 OUT=3D MAC=3D=
ff:ff:ff:ff:ff:ff:00:50:73:6c:4b:e5:08:00 SRC=3D189.31.180.2 DST=3D255.=
255.255.255 LEN=3D48 TOS=3D0x00 PREC=3D0x00 TTL=3D116 ID=3D20607 DF PRO=
TO=3DTCP SPT=3D4038 DPT=3D4899 WINDOW=3D65535 RES=3D0x00 SYN URGP=3D0=20
Sep 13 20:01:21 teleporto vmunix: DROP [INPUT]: IN=3Deth0 OUT=3D MAC=3D=
ff:ff:ff:ff:ff:ff:00:50:73:6c:4b:e5:08:00 SRC=3D189.31.180.2 DST=3D255.=
255.255.255 LEN=3D48 TOS=3D0x00 PREC=3D0x00 TTL=3D116 ID=3D20616 DF PRO=
TO=3DTCP SPT=3D4054 DPT=3D4899 WINDOW=3D65535 RES=3D0x00 SYN URGP=3D0=20
Sep 13 20:01:21 teleporto vmunix: C193.8. S=3D5.5.5.5 E=3D8TS00 RC00 T=3D=
1 D262DF PROTO=3DTCP SPT=3D4146 DPT=3D4899 WINDOW=3D65535 RES=3D0x00 SY=
N URGP=3D0=20
Sep 13 20:01:22 teleporto vmunix: DROP [INPUT]: IN=3Deth0 OUT=3D MAC=3D=
ff:ff:ff:ff:ff:ff:00:50:73:6c:4b:e5:08:00 SRC=3D189.31.180.2 DST=3D255.=
255.255.255 LEN=3D48 TOS=3D0x00 PREC=3D0x00 TTL=3D116 ID=3D20690 DF PRO=
TO=3DTCP SPT=3D4179 DPT=3D4899 WINDOW=3D65535 RES=3D0x00 SYN URGP=3D0=20
Sep 13 20:01:22 teleporto vmunix: DROP [INPUT]: IN=3Deth0 OUT=3D MAC=3D=
ff:ff:ff:ff:ff:ff:00:50:73:6c:4b:e5:08:00 SRC=3D189.31.180.2 DST=3D255.=
255.255.255 LEN=3D48 TOS=3D0x00 PREC=3D0x00 TTL=3D116 ID=3D20698 DF PRO=
TO=3DTCP SPT=3D4201 DPT=3D4899 WINDOW=3D65535 RES=3D0x00 SYN URGP=3D0=20
Sep 13 20:01:22 teleporto vmunix: DROP [INPUT]: IN=3Deth0 OUT=3D MAC=3D=
ff:ff:ff:ff:ff:ff:00:50:73:6c:4b:e5:08:00 SRC=3D189.31.180.2 DST=3D255.=
255.255.255 LEN=3D48 TOS=3D0x00 PREC=3D0x00 TTL=3D116 ID=3D20707 DF PRO=
TO=3DTCP SPT=3D4231 DPT=3D4899 WINDOW=3D65535 RES=3D0x00 SYN URGP=3D0=20
Sep 13 20:01:22 teleporto vmunix: DROP [INPUT]: IN=3Deth0 OUT=3D MAC=3D=
ff:ff:ff:ff:ff:ff:00:50:73:6c:4b:e5:08:00 SRC=3D189.31.180.2 DST=3D255.=
255.255.255 LEN=3D48 TOS=3D0x00 PREC=3D0x00 TTL=3D116 ID=3D20725 DF PRO=
TO=3DTCP SPT=3D4294 DPT=3D4899 WINDOW=3D65535 RES=3D0x00 SYN URGP=3D0=20
Sep 13 20:01:22 teleporto vmunix: OOTPST45 P=3D89WNO=3D53 E=3Dx0SNUG=3D=
=20

	I mean these lines:

Sep 13 20:01:21 teleporto vmunix: C193.8. S=3D5.5.5.5 E=3D8TS00 RC00 T=3D=
1 D262DF PROTO=3DTCP SPT=3D4146 DPT=3D4899 WINDOW=3D65535 RES=3D0x00 SY=
N URGP=3D0=20
Sep 13 20:01:22 teleporto vmunix: OOTPST45 P=3D89WNO=3D53 E=3Dx0SNUG=3D=
=20

	This was registered during a stall. I didn't collect more data because=
 I had to restore the server as fast as I can.

	If it doesn't help or doen't mean anything useful, please ignore.

--=20
