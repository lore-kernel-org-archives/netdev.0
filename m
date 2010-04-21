From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: cxgb4: Use ntohs() on __be16 value instead of htons()
Date: Wed, 21 Apr 2010 12:17:43 -0700
Message-ID: <4BCF4F57.4050802@chelsio.com>
References: <ada1ve8r832.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13011 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141Ab0DUTRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 15:17:45 -0400
In-Reply-To: <ada1ve8r832.fsf@roland-alpha.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/21/2010 11:09 AM, Roland Dreier wrote:
> Use the correct direction of byte-swapping function to fix a mistake
> shown by sparse endianness checking -- c.fl0id is __be16.
>
> Signed-off-by: Roland Dreier<rolandd@cisco.com>

Yes, thanks.

Acked-by: Dimitris Michailidis <dm@chelsio.com>

> ---
>   drivers/net/cxgb4/sge.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
> index 14adc58..70bf2b2 100644
> --- a/drivers/net/cxgb4/sge.c
> +++ b/drivers/net/cxgb4/sge.c
> @@ -2047,7 +2047,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
>   	adap->sge.ingr_map[iq->cntxt_id] = iq;
>
>   	if (fl) {
> -		fl->cntxt_id = htons(c.fl0id);
> +		fl->cntxt_id = ntohs(c.fl0id);
>   		fl->avail = fl->pend_cred = 0;
>   		fl->pidx = fl->cidx = 0;
>   		fl->alloc_failed = fl->large_alloc_failed = fl->starving = 0;
>

