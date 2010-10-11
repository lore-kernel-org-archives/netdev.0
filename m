From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/5] bnx2x: save cycles in setting gso_size
Date: Sun, 10 Oct 2010 20:52:54 -0700 (PDT)
Message-ID: <20101010.205254.193716921.davem@davemloft.net>
References: <1286749675.4669.24.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladz@broadcom.com, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44896
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753091Ab0JKDwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Oct 2010 23:52:32 -0400
In-Reply-To: <1286749675.4669.24.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Mon, 11 Oct 2010 00:27:55 +0200

> diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
> index cb2a3d6..ddf90e1 100644
> --- a/drivers/net/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> @@ -277,8 +277,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
>  
>  	/* This is needed in order to enable forwarding support */
>  	if (frag_size)
> -		skb_shinfo(skb)->gso_size = min((u32)SGE_PAGE_SIZE,
> -					       max(frag_size, (u32)len_on_bd));
> +		skb_shinfo(skb)->gso_size = 1;
>  

I wonder why you need to set this here.

When you pass this packet into the stack, dev_gro_receive() is going
to set ->gro_size() unconditionally if any GRO processing is going to
occur at all.

Why do you need to set it at all?

And if we do need it, doesn't every driver that builds fragmented SKBs?
And if it's correct, why is setting a don't care value like "1" ok and
will not cause problems to whoever cares about this value?

I really want all of these questions answered, and at least lightly
explained in the commit message before I apply this patch.

Thanks.
