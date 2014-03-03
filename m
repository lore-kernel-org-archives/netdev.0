From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv2 net-next 09/31] iw_cxgb4: Treat CPL_ERR_KEEPALV_NEG_ADVICE
 as negative advice.
Date: Mon, 03 Mar 2014 21:44:24 +0300
Message-ID: <5314CD88.5060701@cogentembedded.com>
References: <1393828875-13452-1-git-send-email-hariprasad@chelsio.com> <1393828875-13452-10-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, roland@purestorage.com, kumaras@chelsio.com,
	dm@chelsio.com, swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, nirranjan@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:47952 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603AbaCCRo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 12:44:28 -0500
Received: by mail-la0-f42.google.com with SMTP id ec20so4867577lab.15
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 09:44:26 -0800 (PST)
In-Reply-To: <1393828875-13452-10-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/03/2014 09:40 AM, Hariprasad Shenai wrote:

> From: Steve Wise <swise@opengridcomputing.com>

> Based on original work by Anand Priyadarshee <anandp@chelsio.com>.

> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> ---
>   drivers/infiniband/hw/cxgb4/cm.c            |   25 +++++++++++++------------
>   drivers/net/ethernet/chelsio/cxgb4/t4_msg.h |    1 +
>   2 files changed, 14 insertions(+), 12 deletions(-)

> diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
> index 74a2250..9387f74 100644
> --- a/drivers/infiniband/hw/cxgb4/cm.c
> +++ b/drivers/infiniband/hw/cxgb4/cm.c
> @@ -1648,6 +1648,16 @@ static inline int act_open_has_tid(int status)
>   	       status != CPL_ERR_ARP_MISS;
>   }
>
> +/*
> + * Returns whether a CPL status conveys negative advice.

    Could fix the comment style to comply with the networking coding standards 
while at it.

> + */
> +static int is_neg_adv(unsigned int status)
> +{
> +	return status == CPL_ERR_RTX_NEG_ADVICE ||
> +	       status == CPL_ERR_PERSIST_NEG_ADVICE ||
> +	       status == CPL_ERR_KEEPALV_NEG_ADVICE;
> +}
> +
>   #define ACT_OPEN_RETRY_COUNT 2
>
>   static int import_ep(struct c4iw_ep *ep, int iptype, __u8 *peer_ip,
[...]
> @@ -2266,15 +2276,6 @@ static int peer_close(struct c4iw_dev *dev, struct sk_buff *skb)
>   	return 0;
>   }
>
> -/*
> - * Returns whether an ABORT_REQ_RSS message is a negative advice.
> - */
> -static int is_neg_adv_abort(unsigned int status)
> -{
> -	return status == CPL_ERR_RTX_NEG_ADVICE ||
> -	       status == CPL_ERR_PERSIST_NEG_ADVICE;
> -}
> -
>   static int peer_abort(struct c4iw_dev *dev, struct sk_buff *skb)
>   {
>   	struct cpl_abort_req_rss *req = cplhdr(skb);

WBR, Sergei
