From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next PATCH 3/5] bpf: cpumap xdp_buff to skb conversion and
 allocation
Date: Fri, 29 Sep 2017 17:49:23 +0800
Message-ID: <1c37f945-0e2f-1eec-fe88-a740815026d3@redhat.com>
References: <150660339205.2808.7084136789768233829.stgit@firesoul>
 <150660343811.2808.7680200486950101509.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48194 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750926AbdI2Jtp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 05:49:45 -0400
In-Reply-To: <150660343811.2808.7680200486950101509.stgit@firesoul>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年09月28日 20:57, Jesper Dangaard Brouer wrote:
> +};
> +
> +/* Convert xdp_buff to xdp_pkt */
> +static struct xdp_pkt *convert_to_xdp_pkt(struct xdp_buff *xdp)
> +{
> +	struct xdp_pkt *xdp_pkt;
> +	int headroom;
> +
> +	/* Assure headroom is available for storing info */
> +	headroom = xdp->data - xdp->data_hard_start;
> +	if (headroom < sizeof(*xdp_pkt))
> +		return NULL;

Hi Jesper:

Do you consider this as a trick or a long term solution? Is it better to 
store XDP in a circular buffer? (I'm asking since I meet similar issue 
when doing xdp_xmit for tun).

> +
> +	/* Store info in top of packet */
> +	xdp_pkt = xdp->data_hard_start;
> +
> +	xdp_pkt->data = xdp->data;
> +	xdp_pkt->len  = xdp->data_end - xdp->data;
> +	xdp_pkt->headroom = headroom - sizeof(*xdp_pkt);
> +

Is wmb() needed here?

> +	return xdp_pkt;
> +}

Thanks
