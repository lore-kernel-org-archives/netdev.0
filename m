From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] bna: fix vlan tag stripping and implement its
 toggling
Date: Fri, 28 Feb 2014 10:24:47 +0100
Message-ID: <20140228092447.GC2823@minipsycho.orion>
References: <1393578674-12658-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, rmody@brocade.com
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:33018 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbaB1JY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 04:24:59 -0500
Received: by mail-ee0-f44.google.com with SMTP id d49so2101118eek.3
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 01:24:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1393578674-12658-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>+int bnad_set_features(struct net_device *dev, netdev_features_t features)
>+{
>+	struct bnad *bnad = netdev_priv(dev);
>+	netdev_features_t changed = features ^ dev->features;
>+
>+	if ((changed & NETIF_F_HW_VLAN_CTAG_RX) && netif_running(dev)) {
                                                   ^^^^^^^^^^^^^^^^^^
							   why?
	
>+		unsigned long flags;
>+
>+		spin_lock_irqsave(&bnad->bna_lock, flags);
>+
>+		if (features & NETIF_F_HW_VLAN_CTAG_RX)
>+			bna_rx_vlan_strip_enable(bnad->rx_info[0].rx);
>+		else
>+			bna_rx_vlan_strip_disable(bnad->rx_info[0].rx);
>+
>+		spin_unlock_irqrestore(&bnad->bna_lock, flags);
>+	}
>+
>+	return 0;
>+}
