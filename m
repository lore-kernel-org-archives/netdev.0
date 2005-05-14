From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 11/12] orinoco: monitor mode support
Date: Sat, 14 May 2005 19:39:47 +0200
Message-ID: <20050514173947.GA32235@electric-eye.fr.zoreil.com>
References: <20050514153100.GL3643@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, proski@gnu.org, hermes@gibson.dropbear.id.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
Content-Disposition: inline
In-Reply-To: <20050514153100.GL3643@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig <hch@lst.de> :
[...]
> +	skb = dev_alloc_skb(hdrlen + datalen);
> +	if (!skb) {
> +		printk(KERN_WARNING "%s: Cannot allocate skb for monitor frame\n",
> +		       dev->name);
> +		err = -ENOMEM;
> +		goto drop;
> +	}
> +
> +	/* Copy the 802.11 header to the skb */
> +	memcpy(skb_put(skb, hdrlen), &(desc->frame_ctl), hdrlen);
> +	skb->mac.raw = skb->data;
> +
> +	/* If any, copy the data from the card to the skb */
> +	if (datalen > 0) {
> +		err = hermes_bap_pread(hw, IRQ_BAP, skb_put(skb, datalen),
> +				       ALIGN(datalen, 2), rxfid,
> +				       HERMES_802_2_OFFSET);
> +		if (err) {
> +			printk(KERN_ERR "%s: error %d reading monitor frame\n",
> +			       dev->name, err);
> +			goto drop;
[...]
> + drop:
> +	stats->rx_errors++;
> +	stats->rx_dropped++;
> +}

-> leak (skb).

--
Ueimor
