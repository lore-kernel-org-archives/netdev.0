From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH -next] xen-netback: fix fragments error handling in
 checksum_setup_ip()
Date: Mon, 16 Dec 2013 09:40:37 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD01B4F4C@AMSPEX01CL01.citrite.net>
References: <CAPgLHd97T5bVtCEubkNqChBjSoA5V4Cka=ZQUn=JoYjPCuVE6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:17282 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539Ab3LPJkk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 04:40:40 -0500
In-Reply-To: <CAPgLHd97T5bVtCEubkNqChBjSoA5V4Cka=ZQUn=JoYjPCuVE6A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Yongjun [mailto:weiyj.lk@gmail.com]
> Sent: 16 December 2013 02:45
> To: Ian Campbell; Wei Liu; Paul Durrant; Zoltan Kiss; davem@davemloft.net
> Cc: yongjun_wei@trendmicro.com.cn; xen-devel@lists.xenproject.org;
> netdev@vger.kernel.org
> Subject: [PATCH -next] xen-netback: fix fragments error handling in
> checksum_setup_ip()
> 
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return -EPROTO error if fragments detected in checksum_setup_ip().
> 
> Fixes: 1431fb31ecba ('xen-netback: fix fragment detection in checksum
> setup')
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/xen-netback/netback.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-
> netback/netback.c
> index 800496b..773b731 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1099,6 +1099,9 @@ static int checksum_setup_ip(struct xenvif *vif,
> struct sk_buff *skb,
> 
>  	err = -EPROTO;
> 
> +	if (fragment)
> +		goto out;
> +

Good grief. This hunk must have got lost from my original patch. My old tree has it there. So...

Reviewed-by: Paul Durrant <paul.durrant@citrix.com>

>  	switch (ip_hdr(skb)->protocol) {
>  	case IPPROTO_TCP:
>  		err = maybe_pull_tail(skb,
