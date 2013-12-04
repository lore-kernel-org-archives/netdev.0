From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] sctp: disable max_burst when the max_burst is 0
Date: Wed, 04 Dec 2013 09:28:03 -0500
Message-ID: <529F3BF3.40009@gmail.com>
References: <529C2E01.3090005@huawei.com> <529EF6B7.7000501@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>
To: Wang Weidong <wangweidong1@huawei.com>, nhorman@tuxdriver.com,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:54152 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301Ab3LDO2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 09:28:06 -0500
In-Reply-To: <529EF6B7.7000501@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2013 04:32 AM, Wang Weidong wrote:
> As Michael pointed out that when max_burst is 0, it just disable
> max_burst. It declared in rfc6458#section-8.1.24. so add the check
> in sctp_transport_burst_limited, when it 0, just do nothing.
> 
> Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
> Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
> Suggested-by: Michael Tuexen <Michael.Tuexen@lurchi.franken.de>
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/sctp/transport.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> index e332efb..efc46ff 100644
> --- a/net/sctp/transport.c
> +++ b/net/sctp/transport.c
> @@ -573,7 +573,7 @@ void sctp_transport_burst_limited(struct sctp_transport *t)
>  	u32 old_cwnd = t->cwnd;
>  	u32 max_burst_bytes;
>  
> -	if (t->burst_limited)
> +	if (t->burst_limited || asoc->max_burst == 0)
>  		return;
>  
>  	max_burst_bytes = t->flight_size + (asoc->max_burst * asoc->pathmtu);
> 

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Thanks
-vlad
