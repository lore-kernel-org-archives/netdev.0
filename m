From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] isdn: correctly check failed allocation
Date: Thu, 15 Oct 2015 23:32:30 -0700 (PDT)
Message-ID: <20151015.233230.2252642607405342754.davem@davemloft.net>
References: <1444926568-29572-1-git-send-email-wuninsu@gmail.com>
	<1444926568-29572-2-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu
To: wuninsu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444926568-29572-2-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Insu Yun <wuninsu@gmail.com>
Date: Thu, 15 Oct 2015 12:29:28 -0400

> Since skb_clone is memory allocation, it could be failed when lack of resource.
> Therefore, return value of skb_clone needs to be checked and handle error.
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>
> ---
>  drivers/isdn/mISDN/layer2.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
> index 949cabb..888c610 100644
> --- a/drivers/isdn/mISDN/layer2.c
> +++ b/drivers/isdn/mISDN/layer2.c
> @@ -1509,6 +1509,12 @@ l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
>  	}
>  
>  	nskb = skb_clone(skb, GFP_ATOMIC);
> +  if (!nskb) {
> +			printk(KERN_WARNING "%s: no skb mem in %s\n",
> +			       mISDNDevName4ch(&l2->ch), __func__);
> +			return;
> +  }
> +

Again you have indented this code incorrectly.
