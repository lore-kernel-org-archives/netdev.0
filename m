From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH] chelsio: Fix non-NAPI compile
Date: Wed, 21 Feb 2007 00:05:58 -0800
Message-ID: <45DBFD66.7070305@chelsio.com>
References: <20070220235759.102686172@linux-foundation.org> <adamz38c55r.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:11350 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbXBUIHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 03:07:45 -0500
In-Reply-To: <adamz38c55r.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
> Chelsio without NAPI enabled has been broken (won't compile) since
> 3de00b89 ("chelsio: NAPI speed improvement"):
>
>     drivers/net/chelsio/sge.c: In function `t1_interrupt`:
>     drivers/net/chelsio/sge.c:1716: error: `Q` undeclared (first use in this function)
>
> The change below seems to add back in the declaration and
> initialization of `Q` that was removed by mistake, and at least makes
> the driver compile for me, although I have no hardware and hence no
> way to test whether this actually works.
>
> Signed-off-by: Roland Dreier <rolandd@cisco.com>
>   
Roland,

You beat me :)

Cheers,
Divy

> ---
> Hi Stephen, since you seem to be looking after this driver a little
> bit (and since you broke it ;), I'll send this patch to you.
>
> If this seems right to you, please merge it (although perhaps it would
> make more sense just to kill the non-NAPI code, since no one noticed
> it didn't compile).
>
>
> diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
> index 89a6827..326d4a6 100644
> --- a/drivers/net/chelsio/sge.c
> +++ b/drivers/net/chelsio/sge.c
> @@ -1696,6 +1696,7 @@ irqreturn_t t1_interrupt(int irq, void *cookie)
>  {
>  	int work_done;
>  	struct adapter *adapter = cookie;
> +	struct respQ *Q = &adapter->sge->respQ;
>  
>  	spin_lock(&adapter->async_lock);
>  
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

