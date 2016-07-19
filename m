From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH] WiMAX-i2400m: Delete an unnecessary check before the
 function call "kfree_skb"
Date: Tue, 19 Jul 2016 22:11:20 +0200
Message-ID: <b54b9abe-8271-ddc2-5346-7b63d5030189@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>
 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
 <530A086E.8010901@users.sourceforge.net>
 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
 <530A72AA.3000601@users.sourceforge.net>
 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
 <530B5FB6.6010207@users.sourceforge.net>
 <alpine.DEB.2.10.1402241710370.2074@hadrien>
 <530C5E18.1020800@users.sourceforge.net>
 <alpine.DEB.2.10.1402251014170.2080@hadrien>
 <530CD2C4.4050903@users.sourceforge.net>
 <alpine.DEB.2.10.1402251840450.7035@hadrien>
 <530CF8FF.8080600@users.sourceforge.net>
 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>
 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
 <5317A59D.4@users.sourceforge.net> <5649AE81.6070809@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5649AE81.6070809@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 16 Nov 2015 11:17:55 +0100
> 
> The kfree_skb() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/net/wimax/i2400m/control.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
> index 4c41790..4de22b7 100644
> --- a/drivers/net/wimax/i2400m/control.c
> +++ b/drivers/net/wimax/i2400m/control.c
> @@ -644,7 +644,7 @@ void i2400m_msg_to_dev_cancel_wait(struct i2400m *i2400m, int code)
>  
>  	spin_lock_irqsave(&i2400m->rx_lock, flags);
>  	ack_skb = i2400m->ack_skb;
> -	if (ack_skb && !IS_ERR(ack_skb))
> +	if (!IS_ERR(ack_skb))
>  		kfree_skb(ack_skb);
>  	i2400m->ack_skb = ERR_PTR(code);
>  	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
> 

How do you think about to integrate this update suggestion
into another source code repository?

Regards,
Markus
