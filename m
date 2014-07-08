From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3 v4] pktgen: Fill the payload optionally
 with a pattern
Date: Tue, 08 Jul 2014 11:28:38 -0700 (PDT)
Message-ID: <20140708.112838.2087453949565741801.davem@davemloft.net>
References: <1404330855-24546-1-git-send-email-zoltan.kiss@citrix.com>
	<1404330855-24546-2-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, minipli@googlemail.com,
	dborkman@redhat.com, tgraf@suug.ch, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404330855-24546-2-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Wed, 2 Jul 2014 20:54:13 +0100

> @@ -1129,11 +1133,13 @@ static ssize_t pktgen_if_write(struct file *file,
>  		i += len;
>  
>  		if (node_possible(value)) {
> +			int j;
>  			pkt_dev->node = value;
>  			sprintf(pg_result, "OK: node=%d", pkt_dev->node);
> -			if (pkt_dev->page) {
> -				put_page(pkt_dev->page);
> -				pkt_dev->page = NULL;
> +			for (j = 0; j < MAX_SKB_FRAGS; ++j)
> +				if (pkt_dev->pages[j]) {
> +					put_page(pkt_dev->pages[j]);
> +					pkt_dev->pages[j] = NULL;
>  			}
>  		}

I'm scratching my head with the bracing created here, and it's because
the indentation is wrong:

	for () /* <-- no openning curly brace */
		if () {
			x;
			y;
	} /* <-- thus, wrong indentation */

Please resubmit this series with this fixed and #3 adjusted as per the
feedback you've received.

Thanks.
