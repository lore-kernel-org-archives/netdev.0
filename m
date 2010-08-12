From: Ulrich Weber <uweber@astaro.com>
Subject: Re: [PATCH] iproute2: dont filter cached routes on iproute_get
Date: Thu, 12 Aug 2010 11:20:45 +0200
Message-ID: <4C63BCED.5000209@astaro.com>
References: <20100808193304.GA15380@amd64.fatal.se>	<AANLkTim4h7rTJuF7UWAE-p_4NGkrwksUjoK6m2x5BubG@mail.gmail.com>	<1281297165.4116.19.camel@amd64.fatal.se>	<20100812090519.GA13769@babylon> <AANLkTikKbNPXv+F6SuR79Q9qcS1WD1DOYLGuOtuLkzuK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andreas Henriksson <andreas@fatal.se>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Fabio Comolli <fabio.comolli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-74.dex002.intermedia.net ([64.78.20.104]:59742 "EHLO
	DHOST002-74.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753000Ab0HLJUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 05:20:48 -0400
In-Reply-To: <AANLkTikKbNPXv+F6SuR79Q9qcS1WD1DOYLGuOtuLkzuK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch should be applied on top of iproute2 v2.6.35.

Cheers
 Ulrich

On 08/12/2010 11:12 AM, Fabio Comolli wrote:
> Hi.
> Is this patch supposed to be applied on top of plain iproute2 v2.6.35
> or on top of the previous Andreas' patch?
>=20
>=20
>=20
> On Thu, Aug 12, 2010 at 11:05 AM, Ulrich Weber <uweber@astaro.com> wr=
ote:
>> iproute_get will return cloned routes for IPv4
>> and cloned as well non-cloned routes for IPv6.
>>
>> Therefore RTM_F_CLONED flag should not be checked
>> for iproute_get routes. Check in print_route will
>> always fail because valid values are 0 and 1.
>>
>> Signed-off-by: Ulrich Weber <uweber@astaro.com>
>> ---
>>  ip/iproute.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/ip/iproute.c b/ip/iproute.c
>> index 711576e..b43933c 100644
>> --- a/ip/iproute.c
>> +++ b/ip/iproute.c
>> @@ -1286,6 +1286,7 @@ int iproute_get(int argc, char **argv)
>>        memset(&req, 0, sizeof(req));
>>
>>        iproute_reset_filter();
>> +       filter.cloned =3D 2;
>>
>>        req.n.nlmsg_len =3D NLMSG_LENGTH(sizeof(struct rtmsg));
>>        req.n.nlmsg_flags =3D NLM_F_REQUEST;
>> --
>> 1.7.0.4
>>
>>


--=20
Ulrich Weber | uweber@astaro.com | Software Engineer
Astaro GmbH & Co. KG | www.astaro.com | Phone +49-721-25516-0 | Fax =E2=
=80=93200
An der RaumFabrik 33a | 76227 Karlsruhe | Germany
