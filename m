From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: ports beeing reused too fast
Date: Sat, 09 May 2009 17:17:09 +0200
Message-ID: <4A059E75.7060008@cosmosbay.com>
References: <200905082311.09414.opurdila@ixiacom.com> <4A052991.5040009@cosmosbay.com> <200905091611.20321.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52638 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbZEIPRT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 11:17:19 -0400
In-Reply-To: <200905091611.20321.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> On Saturday 09 May 2009 09:58:25 Eric Dumazet wrote:
>=20
>>> I've looked over the  code and it looks right, so maybe net_random(=
) is
>>> not random enough? Or maybe there are side effects because of the %
>>> port_range?
>> Random is random :)
>> Probability a port can be reused pretty fast is not nul.
>>
>=20
> Thinking again about it... you are right :)
>=20
>> So yes, behavior you discovered is expected, when we switched port
>> selection from a sequential one (not very secure btw) to a random on=
e.
>>
>> Any strong reason why a firewall would drop a SYN because ports were=
 used
>> in a previous session ?
>=20
> We don't know why the firewall (Cisco FWSM) is dropping the packets, =
may be a=20
> bug, limitation or miss-configuration. We are trying to track this do=
wn with=20
> the firewall vendor.

Normally, the client machine should not reuse a port during the TIME_WA=
IT duration
(TCP_TIMEWAIT_LEN being 60 seconds on linux). Port selection being rand=
om or sequential,
it should avoid all ports recently used.

Maybe this firewall has a longer TIME_WAIT enforcement (something like =
2 minutes)

>=20
>> Previous mode can be restored by application itself, using a bind() =
before
>> connect(), if this application knows it has a very high rate of conn=
ections
>> from a particular host to a particular host. (source ports range bei=
ng
>> small anyway, so your firewall could complain again)
>=20
> Do you mean bind() with port !=3D 0 ? Because I am already using bind=
() before=20
> connect().
>=20

Yes, but its obviously complex to handle at application side...


