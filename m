From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/5] virtio_net: Add XDP support
Date: Fri, 18 Nov 2016 15:21:56 -0800
Message-ID: <1479511316.8455.303.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
         <20161118190017.16137.13910.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, bblanco@plumgrid.com, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35567 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752805AbcKRXV7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 18:21:59 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so21838909pga.2
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 15:21:58 -0800 (PST)
In-Reply-To: <20161118190017.16137.13910.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-11-18 at 11:00 -0800, John Fastabend wrote:


>  static void free_receive_bufs(struct virtnet_info *vi)
>  {
> +	struct bpf_prog *old_prog;
>  	int i;
>  
>  	for (i = 0; i < vi->max_queue_pairs; i++) {
>  		while (vi->rq[i].pages)
>  			__free_pages(get_a_page(&vi->rq[i], GFP_KERNEL), 0);
> +
> +		old_prog = rcu_dereference(vi->rq[i].xdp_prog);

Seems wrong to me.

Are you sure lockdep (with CONFIG_PROVE_RCU=y) was happy with this ?

> +		RCU_INIT_POINTER(vi->rq[i].xdp_prog, NULL);
> +		if (old_prog)
> +			bpf_prog_put(old_prog);
>  	}
>  }
>  
> 
