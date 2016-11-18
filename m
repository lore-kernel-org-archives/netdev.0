From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/5] virtio_net: Add XDP support
Date: Fri, 18 Nov 2016 15:23:42 -0800
Message-ID: <1479511422.8455.305.camel@edumazet-glaptop3.roam.corp.google.com>
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
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32868 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752901AbcKRXXo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 18:23:44 -0500
Received: by mail-pf0-f196.google.com with SMTP id 144so14291934pfv.0
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 15:23:44 -0800 (PST)
In-Reply-To: <20161118190017.16137.13910.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-11-18 at 11:00 -0800, John Fastabend wrote:
> From: Shrijeet Mukherjee <shrijeet@gmail.com>


>  #include <linux/slab.h>
> @@ -81,6 +82,8 @@ struct receive_queue {
>  
>  	struct napi_struct napi;
>  
> +	struct bpf_prog *xdp_prog;

Please add proper sparse annotation, as in 

	struct bpf_prog __rcu *xdp_prog;

And run sparse ;)

CONFIG_SPARSE_RCU_POINTER=y

make C=2 drivers/net/virtio_net.o
