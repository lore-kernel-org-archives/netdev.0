From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT] mv643xxx_eth_start_xmit oops
Date: Fri, 10 Nov 2006 22:30:43 +0100
Message-ID: <20061110213043.GB9453@electric-eye.fr.zoreil.com>
References: <20061110191745.GA13783@codepoet.org> <20061110115444.07f58e40@freekitty> <20061110205327.19468.qmail@farnsworth.org> <20061110210343.GA9453@electric-eye.fr.zoreil.com> <20061110130715.5e99ce9f@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35224 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S966113AbWKJVch
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 16:32:37 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061110130715.5e99ce9f@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> skb_linearize is documented to free skb on failure.

__skb_linearize
-> __pskb_pull_tail
   -> pskb_expand_head
      [...]
        data = kmalloc(size + sizeof(struct skb_shared_info), gfp_mask);
        if (!data)
                goto nodata;
      [...]
nodata:
        return -ENOMEM;

I don't see where the skb is freed on this path.

Btw, the same __skb_linearize() is followed by a kfree_skb() in
drivers/net/via-velocity.c since 364c6badde0dd62a0a38e5ed67f85d87d6665780

I may be wrong but the source code does not seem completely right either.

-- 
Ueimor
