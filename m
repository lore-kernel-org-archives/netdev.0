From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH 4/5] virtio_net: add dedicated XDP transmit queues
Date: Fri, 18 Nov 2016 13:09:53 -0800
Message-ID: <20161118130953.7bf2d71d@laptop>
References: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
        <20161118190041.16137.48399.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, bblanco@plumgrid.com, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:19144 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752173AbcKRVKV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Nov 2016 16:10:21 -0500
In-Reply-To: <20161118190041.16137.48399.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks very cool! :)

On Fri, 18 Nov 2016 11:00:41 -0800, John Fastabend wrote:
> @@ -1542,12 +1546,34 @@ static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
>  		return -EINVAL;
>  	}
>  
> +	curr_qp = vi->curr_queue_pairs - vi->xdp_queue_pairs;
> +	if (prog)
> +		xdp_qp = num_online_cpus();

Is num_online_cpus() correct here?
