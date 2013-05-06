From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [patch 2/2] tipc: potential divide by zero in tipc_link_recv_fragment()
Date: Mon, 06 May 2013 22:38:53 +0400
Message-ID: <5187F8BD.1080900@cogentembedded.com>
References: <20130506182912.GB21347@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:60432 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754826Ab3EFSiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 14:38:55 -0400
Received: by mail-la0-f42.google.com with SMTP id fq13so3623699lab.29
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 11:38:54 -0700 (PDT)
In-Reply-To: <20130506182912.GB21347@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06-05-2013 22:29, Dan Carpenter wrote:

> The worry here is that fragm_sz could be zero since it comes from
> skb->data.

> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

> diff --git a/net/tipc/link.c b/net/tipc/link.c
> index 3a6064b3..de94493 100644
> --- a/net/tipc/link.c
> +++ b/net/tipc/link.c
> @@ -2524,14 +2524,16 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
>   		struct tipc_msg *imsg = (struct tipc_msg *)msg_data(fragm);
>   		u32 msg_sz = msg_size(imsg);
>   		u32 fragm_sz = msg_data_sz(fragm);
> -		u32 exp_fragm_cnt = msg_sz/fragm_sz + !!(msg_sz % fragm_sz);
> +		u32 exp_fragm_cnt;
>   		u32 max =  TIPC_MAX_USER_MSG_SIZE + NAMED_H_SIZE;
> +
>   		if (msg_type(imsg) == TIPC_MCAST_MSG)
>   			max = TIPC_MAX_USER_MSG_SIZE + MCAST_H_SIZE;
> -		if (msg_size(imsg) > max) {
> +		if (fragm_sz == 0 || msg_size(imsg) > max) {
>   			kfree_skb(fbuf);
>   			return 0;
>   		}
> +		exp_fragm_cnt = msg_sz/fragm_sz + !!(msg_sz % fragm_sz);

    Don't you think spaces around / should be added at least for 
consistency with %?

WBR, Sergei
