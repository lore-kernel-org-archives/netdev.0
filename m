From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: irda: delete double assignment
Date: Tue, 29 Jul 2014 15:47:07 -0700 (PDT)
Message-ID: <20140729.154707.2014852273209594700.davem@davemloft.net>
References: <20140728152812.GA3000@himangi-Dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: himangi774@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140728152812.GA3000@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himangi Saraogi <himangi774@gmail.com>
Date: Mon, 28 Jul 2014 20:58:12 +0530

> @@ -621,7 +621,6 @@ void irlap_send_rd_frame(struct irlap_cb *self)
>  
>  	frame = (struct rd_frame *)skb_put(tx_skb, 2);
>  
> -	frame->caddr = self->caddr;
>  	frame->caddr = RD_RSP | PF_BIT;
>  

This doesn't look correct to me.

I think both lines should be kept, and the second line should be
changed to assign those bits to frame->control.

This is consistent with other parts of the file that make use of the PF_BIT.
