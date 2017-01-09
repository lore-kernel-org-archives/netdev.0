From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH] net: qrtr: Mark 'buf' as little endian
Date: Mon, 9 Jan 2017 15:02:14 -0800
Message-ID: <20170109230214.GX10531@minitux>
References: <20170109223158.29255-1-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170109223158.29255-1-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 09 Jan 14:31 PST 2017, Stephen Boyd wrote:

> Failure to mark this pointer as __le32 causes checkers like
> sparse to complain:
> 
> net/qrtr/qrtr.c:274:16: warning: incorrect type in assignment (different base types)
> net/qrtr/qrtr.c:274:16:    expected unsigned int [unsigned] [usertype] <noident>
> net/qrtr/qrtr.c:274:16:    got restricted __le32 [usertype] <noident>
> net/qrtr/qrtr.c:275:16: warning: incorrect type in assignment (different base types)
> net/qrtr/qrtr.c:275:16:    expected unsigned int [unsigned] [usertype] <noident>
> net/qrtr/qrtr.c:275:16:    got restricted __le32 [usertype] <noident>
> net/qrtr/qrtr.c:276:16: warning: incorrect type in assignment (different base types)
> net/qrtr/qrtr.c:276:16:    expected unsigned int [unsigned] [usertype] <noident>
> net/qrtr/qrtr.c:276:16:    got restricted __le32 [usertype] <noident>
> 
> Silence it.
> 
> Cc: Bjorn Andersson <bjorn.andersson@linaro.org>

Acked-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Regards,
Bjorn

> Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
> ---
>  net/qrtr/qrtr.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
> index c985ecbe9bd6..ae5ac175b2be 100644
> --- a/net/qrtr/qrtr.c
> +++ b/net/qrtr/qrtr.c
> @@ -252,7 +252,7 @@ static struct sk_buff *qrtr_alloc_resume_tx(u32 src_node,
>  	const int pkt_len = 20;
>  	struct qrtr_hdr *hdr;
>  	struct sk_buff *skb;
> -	u32 *buf;
> +	__le32 *buf;
>  
>  	skb = alloc_skb(QRTR_HDR_SIZE + pkt_len, GFP_KERNEL);
>  	if (!skb)
> @@ -269,7 +269,7 @@ static struct sk_buff *qrtr_alloc_resume_tx(u32 src_node,
>  	hdr->dst_node_id = cpu_to_le32(dst_node);
>  	hdr->dst_port_id = cpu_to_le32(QRTR_PORT_CTRL);
>  
> -	buf = (u32 *)skb_put(skb, pkt_len);
> +	buf = (__le32 *)skb_put(skb, pkt_len);
>  	memset(buf, 0, pkt_len);
>  	buf[0] = cpu_to_le32(QRTR_TYPE_RESUME_TX);
>  	buf[1] = cpu_to_le32(src_node);
> -- 
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
> a Linux Foundation Collaborative Project
> 
