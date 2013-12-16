From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv3 net-next 6/7] {pktgen, xfrm} Introduce xfrm_state_lookup_byspi
 for pktgen
Date: Mon, 16 Dec 2013 19:38:25 +0800
Message-ID: <52AEE631.3000503@windriver.com>
References: <1387094284-2901-1-git-send-email-fan.du@windriver.com> <1387094284-2901-7-git-send-email-fan.du@windriver.com> <52AE143E.3020807@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <steffen.klassert@secunet.com>,
	<hadi@cyberus.ca>, <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:37045 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753738Ab3LPLik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 06:38:40 -0500
In-Reply-To: <52AE143E.3020807@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8816=E6=97=A5 04:42, Sergei Shtylyov wrote:
> Hello.
>
> On 12/15/2013 10:58 AM, Fan Du wrote:
>
>> Introduce xfrm_state_lookup_byspi to find user specified by custom
>> from "pgset spi xxx". Using this scheme, any flow regardless its
>> saddr/daddr could be transform by SA specified with configurable
>> spi.
>
>> Signed-off-by: Fan Du <fan.du@windriver.com>
> [...]
>
>> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
>> index eb70c23..ae268ff 100644
>> --- a/net/core/pktgen.c
>> +++ b/net/core/pktgen.c
>> @@ -2247,13 +2247,21 @@ static void get_ipsec_sa(struct pktgen_dev *=
pkt_dev, int flow)
>> struct xfrm_state *x =3D pkt_dev->flows[flow].x;
>> struct pktgen_net *pn =3D net_generic(dev_net(pkt_dev->odev), pg_net=
_id);
>> if (!x) {
>> - /*slow path: we dont already have xfrm_state*/
>> - x =3D xfrm_stateonly_find(pn->net, DUMMY_MARK,
>> - (xfrm_address_t *)&pkt_dev->cur_daddr,
>> - (xfrm_address_t *)&pkt_dev->cur_saddr,
>> - AF_INET,
>> - pkt_dev->ipsmode,
>> - pkt_dev->ipsproto, 0);
>> +
>> + if (pkt_dev->spi) {
>> + /* We need as quick as possible to find the right SA
>> + * Searching with minimum criteria to archieve this.
>> + */
>> + x =3D xfrm_state_lookup_byspi(pn->net, htonl(pkt_dev->spi), AF_INE=
T);
>> + } else {
>> + /*slow path: we dont already have xfrm_state*/
>
> Could you insert spaces after /* and before */, while at it?

Sure, I will incorporate this in v4.

Thanks for your attention.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
