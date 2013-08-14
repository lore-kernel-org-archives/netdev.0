From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/6] 6lowpan: introduce lowpan_fetch_skb function
Date: Wed, 14 Aug 2013 14:06:34 +0200
Message-ID: <20130814120634.GD2010@order.stressinduktion.org>
References: <1376478108-3539-1-git-send-email-alex.aring@gmail.com> <1376478108-3539-4-git-send-email-alex.aring@gmail.com> <20130814114921.GC2010@order.stressinduktion.org> <520B7029.3070903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alexander Aring <alex.aring@gmail.com>, dbaryshkov@gmail.com,
	davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51078 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686Ab3HNMGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 08:06:35 -0400
Content-Disposition: inline
In-Reply-To: <520B7029.3070903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 03:55:21PM +0400, Alexander Smirnov wrote:
> On 08/14/2013 03:49 PM, Hannes Frederic Sowa wrote:
> >On Wed, Aug 14, 2013 at 01:01:45PM +0200, Alexander Aring wrote:
> >>This patch adds a helper function to parse the ipv6 header to a
> >>6lowpan header in stream.
> >>
> >>This function checks first if we can pull data with a specific
> >>length from a skb. If this seems to be okay, we copy skb data to
> >>a destination pointer and run skb_pull.
> >>
> >>Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> >>Reviewed-by: Werner Almesberger <werner@almesberger.net>
> >>---
> >>  net/ieee802154/6lowpan.h | 12 ++++++++++++
> >>  1 file changed, 12 insertions(+)
> >>
> >>diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
> >>index 61f0ce9..e3348ec 100644
> >>--- a/net/ieee802154/6lowpan.h
> >>+++ b/net/ieee802154/6lowpan.h
> >>@@ -233,4 +233,16 @@
> >>  					dest = 16 bit inline */
> >>  #define LOWPAN_NHC_UDP_CS_P_11	0xF3 /* source & dest = 0xF0B + 4bit 
> >>  inline */
> >>
> >>+static inline bool lowpan_fetch_skb(struct sk_buff *skb,
> >>+		void *data, const unsigned int len)
> >>+{
> >>+	if (unlikely(!pskb_may_pull(skb, len)))
> >>+		return true;
> >>+
> >>+	skb_copy_from_linear_data(skb, data, len);
> >>+	skb_pull(skb, len);
> >>+
> >>+	return false;
> >>+}
> >
> >Isn't the return value inverted here?
> 
> Nope, everything is right here, but I spent several minutes to get it...
> Probably using of standard intergers will be better here: return -EINVAL 
> and return 0;

Ah, yes, I saw it in your next patch. You could also use false for failure and
true for success. Either way, this seemd a bit unnatural for me.

Thanks,

  Hannes
