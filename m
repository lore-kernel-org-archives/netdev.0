From: =?iso-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
Subject: Re: auto recycling of TIME_WAIT connections
Date: Mon, 10 Sep 2007 11:26:36 +0100
Message-ID: <46E51BDC.10907@draigBrady.com>
References: <46E11829.4090607@draigBrady.com> <46E18489.6060100@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.parkwest.mxsweep.com ([89.149.149.67]:4354 "EHLO
	smtp1.mxsweep.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932790AbXIJK2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 06:28:17 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <46E18489.6060100@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
>> The first issue, requires a large timeout, and
>> the TIME_WAIT timeout is currently 60 seconds on linux.
>> That timeout effectively limits the connection rate between
>> local TCP clients and a server to 32k/60s or around 500
>> connections/second.
>=20
> Actually, it would be more like 60k/60s if the application were makin=
g
> explicit calls to bind() as arguably it should if it is going to be
> churning through so many connections.


> This was an issue over a decade ago with SPECweb96 benchmarking.  The
> initial solution was to make the explicit bind() calls and not rely o=
n
> the anonymous/ephemeral port space.  After that, one starts adding
> additional IP's into the mix (at least where possible).  And if that
> fails, one has to go back to the beginning and ask oneself exactly wh=
y a
> client is trying to churn through so many connections per second in t=
he
> first place.

right. This is for benchmarking mainly.
Sane applications would use persistent connections,
or a different form of IPC.

>=20
> If we were slavishly conformant to the RFC's :) that 60 seconds would=
 be
> 240 seconds...
>=20
>> But that issue can't really happen when the client
>> and server are on the same machine can it, and
>> even if it could, the timeouts involved would be shorter.
>>
>> Now linux does have an (undocumented)
>> /proc/sys/net/ipv4/tcp_tw_recycle flag
>> to enable recycling of TIME_WAIT connections. This is global however
>> and could cause
>> problems in general for external connections.
>=20
> Rampant speculation begins...
>=20
> If the client can be convinced to just call shutdown(SHUT_RDWR) rathe=
r
> than close(), and be the first to do so, ahead of the server, I think=
 it
> will retain a link to the TCP endpoint in TIME_WAIT.  It could then, =
in
> TCP theory, call connect() again, and go through a path that allows
> transition from TIME_WAIT to ESTABLISHED if all the right things wrt
> Initial Sequence Number selection happen.  Whether randomization of t=
he
> ISN allows that today is questionable.

Sounds good, unfortunately connect() returns EISCONN
unless you do a close().

>=20
>> So how about auto enabling recycling for local connections?
>=20
> I think the standard response is that one can never _really_ know wha=
t
> is local and what not, particularly in the presence of netfilter and =
the
> rewriting of headers behind one's back.

Hmm, I was afraid someone would say that :)

thanks for the feedback,
P=E1draig.
