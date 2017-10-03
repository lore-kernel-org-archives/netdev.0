From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V3 PATCH 3/5] bpf: cpumap xdp_buff to skb conversion
 and allocation
Date: Tue, 3 Oct 2017 16:18:46 +0200
Message-ID: <20171003161846.4f2e2733@redhat.com>
References: <150696027949.24152.7507025809123255386.stgit@firesoul>
        <150696032966.24152.3096148163967111058.stgit@firesoul>
        <20171003010245.f3op4t56crbjc4ke@ast-mbp>
        <20171003085843.14d3491e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38524 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751156AbdJCOS5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 10:18:57 -0400
In-Reply-To: <20171003085843.14d3491e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Oct 2017 08:58:43 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> > But that prog can do cpumap redirect again?
> > sort-of recursive redirect? Is it really useful?
> > May be call into __netif_receive_skb_core() directly?
> > not sure.  
> 
> I like the idea of calling  __netif_receive_skb_core() directly.  I'll
> send a V4 (after running my different benchmarks).

Using __netif_receive_skb_core() was straight forward/easy.

But I realized I had forgotten about Generic-XDP, which I also need to
code up.  And with Generic-XDP we cannot invoke netif_receive_skb(),
because it would recursively invoke itself (which you actually point out
above, thx).  I'll send a V4 out tomorrow.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
