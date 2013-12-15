From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv3 net-next 6/7] {pktgen, xfrm} Introduce xfrm_state_lookup_byspi
 for pktgen
Date: Sun, 15 Dec 2013 23:42:38 +0300
Message-ID: <52AE143E.3020807@cogentembedded.com>
References: <1387094284-2901-1-git-send-email-fan.du@windriver.com> <1387094284-2901-7-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:63667 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631Ab3LOTmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 14:42:40 -0500
Received: by mail-la0-f42.google.com with SMTP id ec20so2362487lab.15
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 11:42:38 -0800 (PST)
In-Reply-To: <1387094284-2901-7-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/15/2013 10:58 AM, Fan Du wrote:

> Introduce xfrm_state_lookup_byspi to find user specified by custom
> from "pgset spi xxx". Using this scheme, any flow regardless its
> saddr/daddr could be transform by SA specified with configurable
> spi.

> Signed-off-by: Fan Du <fan.du@windriver.com>
[...]

> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index eb70c23..ae268ff 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -2247,13 +2247,21 @@ static void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
>   	struct xfrm_state *x = pkt_dev->flows[flow].x;
>   	struct pktgen_net *pn = net_generic(dev_net(pkt_dev->odev), pg_net_id);
>   	if (!x) {
> -		/*slow path: we dont already have xfrm_state*/
> -		x = xfrm_stateonly_find(pn->net, DUMMY_MARK,
> -					(xfrm_address_t *)&pkt_dev->cur_daddr,
> -					(xfrm_address_t *)&pkt_dev->cur_saddr,
> -					AF_INET,
> -					pkt_dev->ipsmode,
> -					pkt_dev->ipsproto, 0);
> +
> +		if (pkt_dev->spi) {
> +			/* We need as quick as possible to find the right SA
> +		 	 * Searching with minimum criteria to archieve this.
> +		 	 */
> +			x = xfrm_state_lookup_byspi(pn->net, htonl(pkt_dev->spi), AF_INET);
> +		} else {
> +			/*slow path: we dont already have xfrm_state*/

    Could you insert spaces after /* and before */, while at it?

WBR, Sergei
