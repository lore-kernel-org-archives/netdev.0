From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: exploit skb->xmit_more to conditionally
 send doorbell
Date: Thu, 25 Sep 2014 13:47:26 -0700
Message-ID: <1411678046.16953.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140925164333.7cba128a@redhat.com>
	 <1411657615.16953.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411659380.16953.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:48232 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbaIYUr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 16:47:27 -0400
Received: by mail-pd0-f182.google.com with SMTP id p10so11313920pdj.27
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 13:47:27 -0700 (PDT)
In-Reply-To: <1411659380.16953.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 08:36 -0700, Eric Dumazet wrote:

> After patch :
> 
>     32.78%  [kernel]  [k] __copy_skb_header             
>      8.26%  [kernel]  [k] mlx4_en_xmit                  
>      7.25%  [kernel]  [k] __alloc_skb                   
>      7.18%  [kernel]  [k] copy_user_enhanced_fast_string
>      4.39%  [kernel]  [k] skb_segment                   
>      2.87%  [kernel]  [k] memcpy                        
>      2.59%  [kernel]  [k] tcp_sendmsg                   
>      2.50%  [kernel]  [k] _raw_spin_lock                
>      2.38%  [kernel]  [k] dev_hard_start_xmit           
>      1.52%  [kernel]  [k] tcp_gso_segment               
>      1.50%  [kernel]  [k] kmem_cache_alloc_node_trace   
>      1.40%  [kernel]  [k] kmem_cache_alloc_node         
>      1.16%  [kernel]  [k] ip_send_check                 
> 

After __copy_skb_header() optimization I get something even nicer ;)

    19.90%  [kernel]          [k] __copy_skb_header             
    15.16%  [kernel]          [k] skb_segment                   
     7.02%  [kernel]          [k] __alloc_skb                   
     6.89%  [kernel]          [k] copy_user_enhanced_fast_string
     6.60%  [kernel]          [k] mlx4_en_xmit                  
     2.70%  [kernel]          [k] _raw_spin_lock                
     2.68%  [kernel]          [k] memcpy                        
     2.41%  [kernel]          [k] tcp_sendmsg                   

I'll post this patch asap.
