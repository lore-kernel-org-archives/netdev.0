From: Arvid Brodin <arvid.brodin@alten.se>
Subject: Re: [PATCH] net-hsr: Delete unnecessary checks before the function
 call "kfree_skb"
Date: Tue, 24 Nov 2015 14:42:41 +0100
Message-ID: <56546951.9080101@alten.se>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <5647A77E.6040501@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Arvid Brodin <arvid.brodin@alten.se>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5647A77E.6040501@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-11-14 22:28, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 14 Nov 2015 22:23:48 +0100
> 
> The kfree_skb() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the calls is not needed.
> 

> diff --git a/net/hsr/hsr_forward.c b/net/hsr/hsr_forward.c
> index 7871ed6..55ba943 100644
> --- a/net/hsr/hsr_forward.c
> +++ b/net/hsr/hsr_forward.c
> @@ -355,11 +355,8 @@ void hsr_forward_skb(struct sk_buff *skb, struct hsr_port *port)
>  		goto out_drop;
>  	hsr_register_frame_in(frame.node_src, port, frame.sequence_nr);
>  	hsr_forward_do(&frame);
> -
> -	if (frame.skb_hsr != NULL)
> -		kfree_skb(frame.skb_hsr);
> -	if (frame.skb_std != NULL)
> -		kfree_skb(frame.skb_std);
> +	kfree_skb(frame.skb_hsr);
> +	kfree_skb(frame.skb_std);

Thanks for doing checks on the HSR code, and I apologise for the late reply! Not sure if this has
already been applied, but:

You're right of course that these checks are not strictly necessary. However, it is likely that at 
least one of these (.skb_hsr or .skb_std) will be NULL here, so it could be considered nice form to 
check for this and not just trust kfree_skb() to do this. I'm not sure what's considered more 
correct in the kernel, so I will just say that I'm agnostic about this and let others decide.

Again, thanks!

-- 
Arvid Brodin
ALTEN Sweden
www.alten.com | www.alten.se
