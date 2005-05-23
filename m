From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH 11/12] orinoco: monitor mode support
Date: Sun, 22 May 2005 23:40:39 -0400
Message-ID: <1116819639.726.6.camel@dv>
References: <20050514153100.GL3643@lst.de>
	 <20050514173947.GA32235@electric-eye.fr.zoreil.com>
	 <1116358994.5534.2.camel@dv.roinet.com>
	 <20050517212217.GB12936@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@lst.de>, jgarzik@pobox.com,
        hermes@gibson.dropbear.id.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050517212217.GB12936@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello, Francois!

On Tue, 2005-05-17 at 23:22 +0200, Francois Romieu wrote:

> I am not fond of unneeded/hidden state variable. What about:
> 
> +       /* sanity check the length */
> +       if (datalen > IEEE80211_DATA_LEN + 12) {
> +               printk(KERN_DEBUG "%s: oversized monitor frame, "
> +                      "data length = %d\n", dev->name, datalen);
> +               err = -EIO;
> +               goto drop;
>                 ^^^^^^^^^^ -> let's replace by 'goto update_stats;'
> And turn:
> +   drop:
> +       stats->rx_errors++;
> +       stats->rx_dropped++;
> 
> into:
> 
> +   drop:
> +       dev_kfree_skb_irq(skb);     
> +   update_stats:
> +       stats->rx_errors++;
> +       stats->rx_dropped++;
> 
> This way 'goto drop' really drops and the code does not issue a 'goto drop'
> when it actually want to update the stats.

I agree.  Closer look shows that orinoco needs a complete overhaul of
stats in the rx path.  I'm going to fix it in CVS, and I'll post the
patch to netdev after it receives some testing.

-- 
Regards,
Pavel Roskin
