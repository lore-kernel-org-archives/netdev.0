From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC PATCH net-next 3/4] veth: backup classid befor switch net_ns
Date: Fri, 03 Jan 2014 14:45:19 +0400
Message-ID: <52C694BF.3020903@cogentembedded.com>
References: <52C62A52.8050003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	honkiko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
To: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52C62A52.8050003-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 03-01-2014 7:11, Libo Chen wrote:

> dev_forward_skb will clear skb->sk, so we need save classid
> before that, otherwise the skb can not be under control by
> net_cls.

> Signed-off-by: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>   drivers/net/veth.c | 7 +++++++
>   1 file changed, 7 insertions(+)

> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 2ec2041..ce43a2d 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
[...]
> @@ -123,6 +124,12 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
>   	    rcv->features & NETIF_F_RXCSUM)
>   		skb->ip_summed = CHECKSUM_UNNECESSARY;
>
> +	/**

    Why you're using kernel-doc style comments out of place? The format of 
multi-line comments  in the networking code is this:

/* bla
  * bla
  */

> +	 * dev_forward_sbk will clear skb->sk, so save
> +	 * skb->sk->sk_classid for Qos
> +	 */
> +	bk_cls_classid(skb);
> +

WBR, Sergei
