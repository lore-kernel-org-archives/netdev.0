From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] net: pktgen: packet bursting via
 skb->xmit_more
Date: Fri, 26 Sep 2014 00:42:02 -0700
Message-ID: <1411717322.16953.99.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411692382-8898-1-git-send-email-ast@plumgrid.com>
	 <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34855 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbaIZHmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 03:42:05 -0400
Received: by mail-pd0-f176.google.com with SMTP id z10so10929944pdj.35
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 00:42:04 -0700 (PDT)
In-Reply-To: <1411694414.16953.70.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 18:20 -0700, Eric Dumazet wrote:
> On Thu, 2014-09-25 at 17:46 -0700, Alexei Starovoitov wrote:
> > This patch demonstrates the effect of delaying update of HW tailptr.
> > (based on earlier patch by Jesper)
> > 
> > burst=1 is a default. It sends one packet with xmit_more=false
> > burst=2 sends one packet with xmit_more=true and
> >         2nd copy of the same packet with xmit_more=false
> > burst=3 sends two copies of the same packet with xmit_more=true and
> >         3rd copy with xmit_more=false
> 
> > 
> > Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> > Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> > ---
> 
> Perfect, this is what I had in mind, thanks !
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 

By the way with this patch, I now reach 10 Mpps on mlx4 

base line : 5 Mpps

+ skb->xmit_more and quick hack in pjtgen (spinlock/unlock per packet)
-> 7 Mpps

+ burst of 16 packets, no spinlock per packet -> 10 Mpps
