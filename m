From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 4/6] 6lowpan: add udp warning for elided checksum
Date: Thu, 14 Nov 2013 17:50:46 +0100
Message-ID: <20131114165045.GA2346@omega>
References: <1384444132-1427-1-git-send-email-alex.aring@gmail.com>
 <1384444132-1427-5-git-send-email-alex.aring@gmail.com>
 <1384446721.15774.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	jukka.rissanen@linux.intel.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:40266 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755568Ab3KNQux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 11:50:53 -0500
Received: by mail-bk0-f42.google.com with SMTP id w16so1210879bkz.15
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 08:50:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1384446721.15774.5.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 08:32:01AM -0800, Joe Perches wrote:
> On Thu, 2013-11-14 at 16:48 +0100, Alexander Aring wrote:
> > Bit 5 of "UDP LOWPAN_NHC Format" indicate that the checksum can be elided.
> > The host need to calculate the udp checksum afterwards but this isn't
> > supported right now.
> []
> > diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> []
> > @@ -448,9 +448,14 @@ lowpan_uncompress_udp_header(struct sk_buff *skb, struct udphdr *uh)
> >  		pr_debug("uncompressed UDP ports: src = %d, dst = %d\n",
> >  			 ntohs(uh->source), ntohs(uh->dest));
> >  
> > -		/* copy checksum */
> > -		memcpy(&uh->check, &skb->data[0], 2);
> > -		skb_pull(skb, 2);
> > +		/* checksum */
> > +		if (tmp & LOWPAN_NHC_UDP_CS_C) {
> > +			pr_debug("checksum elided currently not supported");
> 
> This looks like it could need ratelimiting
> Also, it should end in "\n".  Maybe use:
> 
> 	pr_debug_ratelimited("checksum elided currently not supported\n");

ah, yes. I will change it.

Thanks

- Alex
