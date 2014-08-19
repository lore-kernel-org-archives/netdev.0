From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 2/2] net: moxa: replace build_skb() with
 netdev_alloc_skb_ip_align() / memcpy()
Date: Tue, 19 Aug 2014 11:31:59 -0700
Message-ID: <1408473119.5604.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1408459784-9385-1-git-send-email-jonas.jensen@gmail.com>
	 <1408459784-9385-2-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	f.fainelli@gmail.com, bhutchings@solarflare.com
To: Jonas Jensen <jonas.jensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:39742 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbaHSScF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 14:32:05 -0400
In-Reply-To: <1408459784-9385-2-git-send-email-jonas.jensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-08-19 at 16:49 +0200, Jonas Jensen wrote:
> build_skb() is used to make skbs out of existing RX ring memory
> which is bad because the RX ring is allocated only once, on probe.
> Memory corruption occur because said memory is reclaimed, i.e.
> __kfree_skb() (and eventually put_page()).
> 
> Replace build_skb() with netdev_alloc_skb_ip_align() and use memcpy().
> Also, synchronize DMA memory before passing skb to napi_gro_receive().
> 
> Addresses https://bugzilla.kernel.org/show_bug.cgi?id=69041

Wow, this driver was really buggy.

Patch is not complete.

Instead of :

priv->rx_buf_size = RX_BUF_SIZE + 
		SKB_DATA_ALIGN(sizeof(struct skb_shared_info));

I think rx_buf_size can now be RX_BUF_SIZE

Another point is that priv->stats seems not needed, as ndev->stats could
be used instead (and remove moxart_mac_get_stats())
