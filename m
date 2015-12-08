From: Per Hurtig <per.hurtig@kau.se>
Subject: Re: [RFC PATCHv2 net-next 1/2] tcp: RTO Restart (RTOR)
Date: Tue, 8 Dec 2015 12:03:39 +0100
Message-ID: <E9F3FABC-D140-48B6-892F-F7BB1BF4B117@kau.se>
References: <cover.1449478261.git.per.hurtig@kau.se> <cover.1449561786.git.per.hurtig@kau.se> <8cd2c4817d86e30b09fe398c6bfcb7a89521bdb3.1449561786.git.per.hurtig@kau.se> <alpine.DEB.2.10.1512081246070.19242@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0 (Mac OS X Mail 9.1 \(3096.5\))
Content-Type: multipart/signed; boundary="Apple-Mail=_6D58332E-3A23-4B48-A9D0-B0EB3A45EEE1"; protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	ncardwell@google.com, nanditad@google.com, tom@herbertland.com,
	Yuchung Cheng <ycheng@google.com>, viro@zeniv.linux.org.uk,
	fw@strlen.de, mleitner@redhat.com, daniel@iogearbox.net,
	willemb@google.com, pasi.sarolahti@iki.fi,
	stephen@networkplumber.org, Netdev <netdev@vger.kernel.org>,
	=?utf-8?Q?Anna_Brunstr=C3=B6m?= <anna.brunstrom@kau.se>,
	apetlund@simula.no, Michael Welzl <michawe@ifi.uio.no>,
	Mohammad Rajiullah <mohammad.rajiullah@kau.se>
To: =?utf-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.38]:33498 "EHLO tiger.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964795AbbLHLDq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 06:03:46 -0500
In-Reply-To: <alpine.DEB.2.10.1512081246070.19242@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_6D58332E-3A23-4B48-A9D0-B0EB3A45EEE1
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8


> On 08 Dec 2015, at 11:50, Ilpo J=C3=A4rvinen =
<ilpo.jarvinen@helsinki.fi> wrote:
>=20
> On Tue, 8 Dec 2015, Per Hurtig wrote:
>=20
>> This patch implements the RTO restart modification (RTOR). When data =
is
>> ACKed, and the RTO timer is restarted, the time elapsed since the =
last
>> outstanding segment was transmitted is subtracted from the calculated =
RTO
>> value. This way, the RTO timer will expire after exactly RTO seconds, =
and
>> not RTO + RTT [+ delACK] seconds.
>>=20
>> This patch also implements a new sysctl (tcp_timer_restart) that is =
used
>> to control the timer restart behavior.
>>=20
>> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
>> ---
>> Documentation/networking/ip-sysctl.txt | 12 ++++++++++++
>> include/net/tcp.h                      |  6 ++++++
>> net/ipv4/sysctl_net_ipv4.c             | 10 ++++++++++
>> net/ipv4/tcp_input.c                   | 29 =
+++++++++++++++++++++++++++++
>> 4 files changed, 57 insertions(+)
>>=20
>> diff --git a/Documentation/networking/ip-sysctl.txt =
b/Documentation/networking/ip-sysctl.txt
>> index 2ea4c45..4094128 100644
>> --- a/Documentation/networking/ip-sysctl.txt
>> +++ b/Documentation/networking/ip-sysctl.txt
>> @@ -591,6 +591,18 @@ tcp_syn_retries - INTEGER
>> 	with the current initial RTO of 1second. With this the final =
timeout
>> 	for an active TCP connection attempt will happen after =
127seconds.
>>=20
>> +tcp_timer_restart - INTEGER
>> +	Controls how the RTO and PTO timers are restarted (RTOR and =
TLPR).
>> +	If set (per timer or combined) the timers are restarted with
>> +	respect to the earliest outstanding segment, to not extend tail =
loss
>> +	latency unnecessarily.
>> +	Possible values:
>> +		0 disables RTOR and TLPR.
>> +		1 enables RTOR.
>> +		2 enables TLPR.
>> +		3 enables RTOR and TLPR.
>> +	Default: 3
>> +
>> tcp_timestamps - BOOLEAN
>> 	Enable timestamps as defined in RFC1323.
>>=20
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index f80e74c..833efb7 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -76,6 +76,11 @@ void tcp_time_wait(struct sock *sk, int state, int =
timeo);
>> /* After receiving this amount of duplicate ACKs fast retransmit =
starts. */
>> #define TCP_FASTRETRANS_THRESH 3
>>=20
>> +/* Disable RTO Restart if the number of outstanding segments is at =
least. */
>> +#define TCP_TIMER_RTORESTART	1
>> +#define TCP_TIMER_TLPRESTART	2
>> +#define TCP_RTORESTART_THRESH	4
>=20
> Unfortunately the comment got now separated from the actual define.
>=20
>=20
> --
> i.
Darn, I knew I missed something. Well, I=E2=80=99ll fix that in the next =
round. Suppose there are more things that could be improved.

Per


--Apple-Mail=_6D58332E-3A23-4B48-A9D0-B0EB3A45EEE1
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCAAGBQJWZrkPAAoJEMzXVkqMT/z2SYMH+wY3nQYFPAY2Za6tenu8sSSf
cbg0GqUlPVFqvjrSMgba8LWzs5TkoI7w6s2BYEnrLNduwo/5FU1s9rAw7uSaSuoa
P1HX/tjk4ftZGPQpdeITH6i3oBqXwN3sTgm1BX18cVNt7fY3SIdOqxYwdAUxRX/d
CFnOt/rF1pDOm+eJMpYCFouQuqzmQSOvHYcudjj1rtmF9+rzrJJlZHYTDClTlz+3
UqgCCfYp8NeCMQkViY0R7FbN1DY26iFZ2zchfdZ6GrbblEir94eKCHPfZnLo5pzL
z1IIUZ4ob5bA3VoHaEMD80sCPmNFpFWXu0ScwzH5gSPh32ZJ8qX7RC31zP3+wc8=
=26l8
-----END PGP SIGNATURE-----

--Apple-Mail=_6D58332E-3A23-4B48-A9D0-B0EB3A45EEE1--
