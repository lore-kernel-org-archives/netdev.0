From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: ports beeing reused too fast
Date: Sat, 09 May 2009 18:16:28 +0200
Message-ID: <4A05AC5C.3020907@cosmosbay.com>
References: <200905082311.09414.opurdila@ixiacom.com> <4A052991.5040009@cosmosbay.com> <200905091611.20321.opurdila@ixiacom.com> <4A059E75.7060008@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36845 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbZEIQQh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 12:16:37 -0400
In-Reply-To: <4A059E75.7060008@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Octavian Purdila a =E9crit :
>> On Saturday 09 May 2009 09:58:25 Eric Dumazet wrote:
>>
>>>> I've looked over the  code and it looks right, so maybe net_random=
() is
>>>> not random enough? Or maybe there are side effects because of the =
%
>>>> port_range?
>>> Random is random :)
>>> Probability a port can be reused pretty fast is not nul.
>>>
>> Thinking again about it... you are right :)
>>
>>> So yes, behavior you discovered is expected, when we switched port
>>> selection from a sequential one (not very secure btw) to a random o=
ne.
>>>
>>> Any strong reason why a firewall would drop a SYN because ports wer=
e used
>>> in a previous session ?
>> We don't know why the firewall (Cisco FWSM) is dropping the packets,=
 may be a=20
>> bug, limitation or miss-configuration. We are trying to track this d=
own with=20
>> the firewall vendor.
>=20
> Normally, the client machine should not reuse a port during the TIME_=
WAIT duration
> (TCP_TIMEWAIT_LEN being 60 seconds on linux). Port selection being ra=
ndom or sequential,
> it should avoid all ports recently used.
>=20
> Maybe this firewall has a longer TIME_WAIT enforcement (something lik=
e 2 minutes)

Another thing to consider is your client/server use or not tcp timestam=
ps (RFC 1323)

# should allow client to use fast reuse of ports (and trigger a firewal=
l problem)
echo 1 >/proc/sys/net/ipv4/tcp_timestamps

If both machines allow tcp timestamps, then same ports can be reused pr=
etty fast.

If firewall doesnt fully understand RFC 1323, it might explain some pro=
blem
with port randomization and shortened time between port reuse.


