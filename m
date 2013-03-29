From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] core: should call pskb_expand_head if skb
 header is cloned in skb_gso_segment in rx path
Date: Fri, 29 Mar 2013 14:59:47 -0400 (EDT)
Message-ID: <20130329.145947.1829620308225114250.davem@davemloft.net>
References: <1364376845-5000-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251Ab3C2S7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 14:59:49 -0400
In-Reply-To: <1364376845-5000-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Wed, 27 Mar 2013 17:34:05 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> 12b0004d1d1 (adjust skb_gso_segment() for calling in rx path) tries to kill warnings
> by checking if ip_summed is CHECK_NONE or not in rx path, since if skb_gso_segment()
> is called on rx path, and ->ip_summed has different meaning.
> 
> but this maybe break skb if skb header is cloned, and not expand the header, since when
> step into skb_mac_gso_segment(), which will still check ip_summed with CHECKSUM_PARTIAL,
> then do gso_send_check(). and after __skb_gso_segment() in queue_gso_packets() of
> openvswitch, queue_userspace_packet() still checks ip_summed with CHECKSUM_PARTIAL,
> and do checksum.
> 
> so I think it is enough to ignore the warning in rx path.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

I'm not going back-and-forth on this issue yet another time.

I want to see discussion amongst people involved in this area
before applying a patch like this, and I'm therefore not applying
this patch for now (you'll have to submit it again after the
discussions take place).
