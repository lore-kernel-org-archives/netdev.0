From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: ports beeing reused too fast
Date: Sat, 09 May 2009 08:58:25 +0200
Message-ID: <4A052991.5040009@cosmosbay.com>
References: <200905082311.09414.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34681 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbZEIG6i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 02:58:38 -0400
In-Reply-To: <200905082311.09414.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> Hi,
>=20
> We've been running into an issue where a firewall would drop packets =
when an=20
> moderate (~360) connection rate was going through it. It looks like t=
he=20
> firewall is dropping the SYNs that reuse ports "too fast".=20
>=20
> We have no issues with Linux 2.6.7, so I guess the behavior changed b=
ecause of=20
> this this commit:
>=20
> commit 6df716340da3a6fdd33d73d7ed4c6f7590ca1c42
> Author: Stephen Hemminger <shemminger@osdl.org>
> Date:   Thu Nov 3 16:33:23 2005 -0800
>=20
>     [TCP/DCCP]: Randomize port selection
>=20
>=20
> Now, I did some tests to confirm my suspicion. Basically, I am simula=
ting a=20
> connection rate test (I've attached the .c to this email) by opening =
up=20
> connections and closing them - one at a time, and noting down the por=
ts used,=20
> then looking for duplicate ports and printing the distance between th=
e=20
> connection no.
>=20
> Here is one of the runs, which make 1000 iterations:
>=20
> listening (port 1242)
>  port reused: 38203: distance 578 (624,46)
>  port reused: 55693: distance 85 (147,62)
>  port reused: 38269: distance 803 (872,69)
>  port reused: 46239: distance 249 (344,95)
>  port reused: 40981: distance 215 (319,104)
>  port reused: 46246: distance 524 (641,117)
>  port reused: 43990: distance 378 (498,120)
>  port reused: 53766: distance 52 (232,180)
>  port reused: 44199: distance 194 (383,189)
>  port reused: 59464: distance 173 (384,211)
>  port reused: 44417: distance 264 (492,228)
>  port reused: 56989: distance 229 (553,324)
>  port reused: 60117: distance 69 (394,325)
>  port reused: 44549: distance 179 (566,387)
>  port reused: 39213: distance 300 (801,501)
>  port reused: 60166: distance 152 (671,519)
>  port reused: 44178: distance 108 (712,604)
>  port reused: 46516: distance 6 (792,786)
>  port reused: 55754: distance 95 (969,874)
> 19 ports were being reused
>=20
> Running the same test on 2.6.7 yields a "0 ports were being reused" o=
n all=20
> tests that I've ran (10 or so).
>=20
> Isn't it desirable to have the behavior from 2.6.7?=20
>=20
> I've looked over the  code and it looks right, so maybe net_random() =
is not=20
> random enough? Or maybe there are side effects because of the % port_=
range?
>=20

Random is random :)
Probability a port can be reused pretty fast is not nul.

So yes, behavior you discovered is expected, when we switched port sele=
ction
from a sequential one (not very secure btw) to a random one.

Any strong reason why a firewall would drop a SYN because ports were us=
ed in a=20
previous session ?

Previous mode can be restored by application itself, using a bind() bef=
ore
connect(), if this application knows it has a very high rate of connect=
ions
from a particular host to a particular host. (source ports range being
small anyway, so your firewall could complain again)


