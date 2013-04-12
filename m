From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 01/11] ixgbe: Support using build_skb in the case
 that jumbo frames are disabled
Date: Fri, 12 Apr 2013 06:31:05 -0700
Message-ID: <1365773465.4459.21.camel@edumazet-glaptop>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1365765866-15741-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1365772204.4459.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:45791 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077Ab3DLNbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 09:31:07 -0400
Received: by mail-pa0-f45.google.com with SMTP id kl13so1466354pab.18
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 06:31:07 -0700 (PDT)
In-Reply-To: <1365772204.4459.10.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 06:10 -0700, Eric Dumazet wrote:

> Strange. I feel you overestimate the final skb->truesize
> 
> The name 'truesize' is a bit misleading here, as its the size of
> skb->head. A better name would have been frag_size, and you should not
> include in it the struct skb_shared_info overhead because build_skb()
> does it :
> 

Oh well, build_skb() does :

size -= SKB_DATA_ALIGN(sizeof(struct skb_shared_info)); 

so your patch is fine, only the @truesize name is misleading.

> skb->truesize will be set to SKB_TRUESIZE(frag_size)
> 
> #define SKB_TRUESIZE(X) ((X) +                                          \
>                          SKB_DATA_ALIGN(sizeof(struct sk_buff)) +       \
>                          SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
> 
> 
