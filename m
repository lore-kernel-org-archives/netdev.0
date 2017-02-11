From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH] net: ethernet: ti: netcp_core: return netdev_tx_t in xmit
Date: Sat, 11 Feb 2017 03:08:41 +0200
Message-ID: <20170211010839.GA4729@khorivan>
References: <1486650254-8976-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <20170210.144521.1768411194584186345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: w-kwok2@ti.com, m-karicheri2@ti.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33118 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751802AbdBKBIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 20:08:46 -0500
Received: by mail-lf0-f50.google.com with SMTP id x1so30631794lff.0
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 17:08:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170210.144521.1768411194584186345.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2017 at 02:45:21PM -0500, David Miller wrote:
> From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> Date: Thu,  9 Feb 2017 16:24:14 +0200
> 
> > @@ -1300,7 +1301,7 @@ static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> >  			dev_warn(netcp->ndev_dev, "padding failed (%d), packet dropped\n",
> >  				 ret);
> >  			tx_stats->tx_dropped++;
> > -			return ret;
> > +			return NETDEV_TX_BUSY;
> >  		}
> >  		skb->len = NETCP_MIN_PACKET_SIZE;
> >  	}
> > @@ -1329,7 +1330,7 @@ static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> >  	if (desc)
> >  		netcp_free_tx_desc_chain(netcp, desc, sizeof(*desc));
> >  	dev_kfree_skb(skb);
> > -	return ret;
> > +	return NETDEV_TX_BUSY;
> >  }
> 
> I really think these should be returning NET_XMIT_DROP.

Yes, it seems here can be a little more changes then, will send new version
later.
