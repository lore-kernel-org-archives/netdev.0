From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: STMMAC: sleep inside atomic
Date: Mon, 6 Sep 2010 11:47:20 +0200
Message-ID: <4C84B8A8.5080503@st.com>
References: <4C8231E8.5090001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:47259 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750890Ab0IFJrc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Sep 2010 05:47:32 -0400
In-Reply-To: <4C8231E8.5090001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi Jiri,
On 9/4/2010 1:47 PM, Jiri Slaby wrote:
>
> Hi,
>
> stanse found that the driver may sleep inside atomic:
> stmmac_resume
>   -> spin_lock
>   -> stmmac_open
>     -> request_irq
>     -> kzalloc(..., GFP_KERNEL);
>     -> init_dma_desc_rings
>       -> kmalloc(..., GFP_KERNEL);
>     -> and many others...
>   -> spin_unlock
>
> Could you fix that?
>
Yes I could ...  kmalloc(...,GFP_KERNEL) can sleep!
I will fix the spinlock usage in the driver's resume function and send a
patch to the mailing list asap.

Many thanks to have found it.

Regards,
Peppe
>
>
> regards,
> --
> js
>
