From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net 2/2] bridge: multicast: start querier timer when running user-space stp
Date: Thu, 18 Jun 2015 20:35:09 +0300
Message-ID: <0872B4B8-66E5-487A-8F75-3A4AA856EBE4@cumulusnetworks.com>
References: <1434540511-648-1-git-send-email-nikolay@cumulusnetworks.com> <1434540511-648-3-git-send-email-nikolay@cumulusnetworks.com> <20150618033740.GB27370@gondor.apana.org.au>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	davem@davemloft.net, sashok@cumulusnetworks.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33889 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755654AbbFRRfM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 13:35:12 -0400
Received: by wicnd19 with SMTP id nd19so29681351wic.1
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 10:35:10 -0700 (PDT)
In-Reply-To: <20150618033740.GB27370@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 18, 2015, at 6:37 AM, Herbert Xu <herbert@gondor.apana.org.au>=
 wrote:
>=20
> On Wed, Jun 17, 2015 at 04:28:31AM -0700, Nikolay Aleksandrov wrote:
>> From: Satish Ashok <sashok@cumulusnetworks.com>
>>=20
>> When STP is running in user-space and querier is configured, the
>> querier timer is not started when a port goes to forwarding state.
>>=20
>> Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> Fixes: eb1d16414339 ("bridge: Add core IGMP snooping support")
>> ---
>> net/bridge/br_stp.c | 3 +++
>> 1 file changed, 3 insertions(+)
>>=20
>> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
>> index fb3ebe615513..1e2f2f1ff6b0 100644
>> --- a/net/bridge/br_stp.c
>> +++ b/net/bridge/br_stp.c
>> @@ -456,6 +456,9 @@ void br_port_state_selection(struct net_bridge *=
br)
>> 				p->topology_change_ack =3D 0;
>> 				br_make_blocking(p);
>> 			}
>> +		} else if (br->stp_enabled =3D=3D BR_USER_STP &&
>> +			   p->state =3D=3D BR_STATE_FORWARDING) {
>> +			br_multicast_enable_port(p);
>> 		}
>=20
> Minor nit, the stp_enabled check appears to be redundant since
> you're in the else clause.
>=20

Right you are, I=E2=80=99ve overlooked it.

> More importantly, I'm not sure about the logic.  For kernel STP,
> we enable the port as soon as we get out of blocking.  IIRC enabling
> the port just means that we start tracking subscriptions/queries
> so it should be OK to do even while we're listening/learning.
>=20
> In any case the logic should be identical whether we use kernel
> STP or user-space STP.
>=20
> So how about removing br_multicast_enable_port from br_make_forward
> and just add it here for both kernel and user-space STP?
>=20
> Thanks,
> --=20
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

Makes sense, I=E2=80=99ll re-spin, test and post a v2. Thank you for th=
e suggestion.

Cheers,
 Nik
