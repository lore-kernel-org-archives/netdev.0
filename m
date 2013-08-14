From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 3/6] 6lowpan: introduce lowpan_fetch_skb function
Date: Wed, 14 Aug 2013 14:45:47 +0200
Message-ID: <20130814124545.GB4303@x61s.8.8.8.8>
References: <1376478108-3539-1-git-send-email-alex.aring@gmail.com>
 <1376478108-3539-4-git-send-email-alex.aring@gmail.com>
 <20130814114921.GC2010@order.stressinduktion.org>
 <520B7029.3070903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:46418 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932202Ab3HNMlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 08:41:55 -0400
Received: by mail-ee0-f42.google.com with SMTP id b45so4849757eek.29
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 05:41:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <520B7029.3070903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

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
> >>  #define LOWPAN_NHC_UDP_CS_P_11	0xF3 /* source & dest = 0xF0B + 4bit inline */
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
> Probably using of standard intergers will be better here: return
> -EINVAL and return 0;
> 

This was the old behaviour, we decide it to make it like this:

fail = ...
fail |= ....

if (fail)
	...

We discussed that already at the linux-zigbee-devel mailinglist.
I don't know what I should do now, on linux-zigbee-devel we decide it to
this way, now we decide it in a other way...

Regards
Alex
