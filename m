From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1 net-next] caif_usb: remove redundant memory message
Date: Mon, 13 Oct 2014 13:34:26 -0700
Message-ID: <1413232466.1287.24.camel@joe-AO725>
References: <1413231946-9914-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413231946-9914-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-10-13 at 22:25 +0200, Fabian Frederick wrote:
> Let MM subsystem display out of memory messages.
[]
> diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
[]
> @@ -87,10 +87,9 @@ static struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
>  {
>  	struct cfusbl *this = kmalloc(sizeof(struct cfusbl), GFP_ATOMIC);
>  
> -	if (!this) {
> -		pr_warn("Out of memory\n");
> +	if (!this)
>  		return NULL;
> -	}
> +
>  	caif_assert(offsetof(struct cfusbl, layer) == 0);
>  
>  	memset(this, 0, sizeof(struct cflayer));

This bit should probably be:

	memset(&this->layer, 0, sizeof(this->layer));

or the allocation above should use kzalloc.
