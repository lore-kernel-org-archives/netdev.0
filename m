From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] tcp: allow timestamps even if SYN packet has tsval=0
Date: Sat, 14 Mar 2009 10:31:03 +0100
Message-ID: <49BB7957.9070809@cosmosbay.com>
References: <49B7ABF2.5040803@cosmosbay.com> <20090311.064710.255854254.davem@davemloft.net> <Pine.LNX.4.64.0903120858550.4697@wrl-59.cs.helsinki.fi> <20090313.142507.47563051.davem@davemloft.net> <Pine.LNX.4.64.0903141015170.5797@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56343 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbZCNJbR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 05:31:17 -0400
In-Reply-To: <Pine.LNX.4.64.0903141015170.5797@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen a =E9crit :
> On Fri, 13 Mar 2009, David Miller wrote:
>=20
>> From: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
>> Date: Thu, 12 Mar 2009 09:26:20 +0200 (EET)
>>
>>> On Wed, 11 Mar 2009, David Miller wrote:
>>>
>>>> From: Eric Dumazet <dada1@cosmosbay.com>
>>>> Date: Wed, 11 Mar 2009 13:17:54 +0100
>>>>
>>>>> So apparently WindowsXP sends a NULL tsval in SYN packet, then
>>>>> subsequent packets get a real value (60498) in this case.
>>>>>
>>>>> This seems to work on other OS as well, so is the following patch
>>>>> considered evil ?  Do we have security concerns or only risking
>>>>> windows client to have slightly wrong rtt estimation at the begin=
ing
>>>>> of the tcp session ?
>>>> I think we'll have to accept this.
>>>>
>>>> I don't see other systems blocking initial ts_ecn values of
>>>> zero like we do.
>>> What about the fact that PAWS could bite us leaving us a hung conne=
ction=20
>>> if timestamp changes too much when we get the first ACK? Though I d=
oubt=20
>>> you can get windows to run long enough for this to become a problem=
 if=20
>>> they always start from zero... ;-)
>> I really don't think it's a real issue, and Windows XP should be hap=
py
>> we're willing to try timestamps at all with it :-)
>=20
> Right. Would it ever become a problem it would certainly possible to=20
> collect the first real timestamp and discard the bogus zero. We just =
need=20
> to be aware on this if some report about unable-to-connect appears on=
ce
> the change gets larger exposure in wild.
>=20
> There could be other broken things such as firewalls zeroing it in SY=
Ns=20
> so the end host might not necessarily even be xp.
>=20

If you believe this could cause unable-to-connect problem, we must reve=
rt the patch,
or implement your work-around :)

Thanks

