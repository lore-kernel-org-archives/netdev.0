From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2] net: dsa: Mock-up driver
Date: Fri, 31 Mar 2017 18:56:22 +0200
Message-ID: <20170331165622.GK12814@lunn.ch>
References: <20170331014321.3248-1-f.fainelli@gmail.com>
 <20170331160601.GC12814@lunn.ch>
 <3952b60b-1c24-487d-7f8d-9cad5dc69dcc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41999 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933296AbdCaQ4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 12:56:25 -0400
Content-Disposition: inline
In-Reply-To: <3952b60b-1c24-487d-7f8d-9cad5dc69dcc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Actually we do not, because netdev_uses_dsa() returns true only when
> dst->rcv is different from NULL. When dst->rcv is NULL we completely
> bypass the DSA hook in eth_type_trans() and everything is well, the
> master network device is the one receiving packets.

static inline bool netdev_uses_dsa(struct net_device *dev)
{
#if IS_ENABLED(CONFIG_NET_DSA)
        if (dev->dsa_ptr != NULL)
                return dsa_uses_tagged_protocol(dev->dsa_ptr);
#endif
        return false;
}

and

static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
{
        return dst->rcv != NULL;
}

Yep, i just needed to dig further...

Thanks
	Andrew
