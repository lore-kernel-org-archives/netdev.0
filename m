From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: [PATCH-RESEND] Removing unneeded statement from tcp_ipv4.c
Date: Tue, 04 Mar 2008 00:18:07 +0100
Message-ID: <47CC872F.9020202@nets.rwth-aachen.de>
References: <47CBFBDA.7000801@nets.rwth-aachen.de>
 <Pine.LNX.4.64.0803031603100.28251@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:63128 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753989AbYCCXRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 18:17:06 -0500
In-reply-to: <Pine.LNX.4.64.0803031603100.28251@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen schrieb:
> On Mon, 3 Mar 2008, Arnd Hannemann wrote:
>=20
>> Avoid setting tstamp_ok because this is done two lines later anyway.
>>
>> Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
>>
>> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>> index 00156bf..a28c4c2 100644
>> --- a/net/ipv4/tcp_ipv4.c
>> +++ b/net/ipv4/tcp_ipv4.c
>> @@ -1302,15 +1302,14 @@ int tcp_v4_conn_request(struct sock *sk, str=
uct sk_buff *skb)
>>                 tmp_opt.saw_tstamp =3D 0;
>>         }
>>
>> -       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
>> +       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval)
>>                 /* Some OSes (unknown ones, but I see them on web se=
rver, which
>>                  * contains information interesting only for windows=
'
>>                  * users) do not send their stamp in SYN. It is easy=
 case.
>>                  * We simply do not advertise TS support.
>>                  */
>>                 tmp_opt.saw_tstamp =3D 0;
>> -               tmp_opt.tstamp_ok=20
>=20
> Please move the comment before the if (), only then can you remove th=
ose=20
> braces safely (without affecting readability, etc.).

Avoid setting tstamp_ok because this is done two lines later anyway.

Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 00156bf..ecef356 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1302,15 +1302,14 @@ int tcp_v4_conn_request(struct sock *sk, struct=
 sk_buff *skb)
                tmp_opt.saw_tstamp =3D 0;
        }

-       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
-               /* Some OSes (unknown ones, but I see them on web serve=
r, which
-                * contains information interesting only for windows'
-                * users) do not send their stamp in SYN. It is easy ca=
se.
-                * We simply do not advertise TS support.
-                */
+       /* Some OSes (unknown ones, but I see them on web server, which
+        * contains information interesting only for windows'
+        * users) do not send their stamp in SYN. It is easy case.
+        * We simply do not advertise TS support.
+        */
+       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval)
                tmp_opt.saw_tstamp =3D 0;
-               tmp_opt.tstamp_ok  =3D 0;
-       }
+
        tmp_opt.tstamp_ok =3D tmp_opt.saw_tstamp;

        tcp_openreq_init(req, &tmp_opt, skb);

