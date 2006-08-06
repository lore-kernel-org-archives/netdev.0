From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 06 Aug 2006 08:33:09 -0400
Message-ID: <1154867589.6269.40.camel@jzny2>
References: <20060804101017.GA17393@gondor.apana.org.au>
	 <1154712532.3117.43.camel@rh4> <20060804110829.62136ebb@dxpl.pdx.osdl.net>
	 <20060804.163111.85390037.davem@davemloft.net>
	 <1154797002.5081.21.camel@jzny2>
	 <20060805230517.GA25468@gondor.apana.org.au>
	 <1154819868.5517.34.camel@jzny2>
	 <20060805231959.GA25768@gondor.apana.org.au>
	 <1154821010.5517.48.camel@jzny2>
	 <20060806025123.GA27051@gondor.apana.org.au>
	 <1154867083.6269.35.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com,
	"Edgar E. Iglesias" <edgar.iglesias@axis.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:39145 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751116AbWHFMdN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 08:33:13 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G9hoh-0003N1-HJ
	for netdev@vger.kernel.org; Sun, 06 Aug 2006 08:33:15 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1154867083.6269.35.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


BTW, if you notice in the attached patch i have:
+       /* number of descriptors needed to wake up netdev */
+       unsigned int waket;
+       /* number of descriptors we allow to prune at a time */
+       unsigned int prunet;

and:

+       /* hard-coding for now, but we should be able to
+        * use ethtool or module params in the future
+       */
+       txdr->prunet = txdr->count>>2;
+       txdr->waket = txdr->count>>3;

i.e the two thresholds are based on the tx ring sizes.

I didnt like TX_WAKE_THRESHOLD and  E1000_TX_WEIGHT hardcoding.
if i make the ring smaller then these values could be invalid.
I also experimented with varying the two thresholds with varying traffic
throughput - lets say results are still magical and i am still looking
at it.

Q: Do you know the historical context of why TX_WAKE_THRESHOLD and
E1000_TX_WEIGHT are hard-coded (and not for example related to the size
of the ring)? Jesse?
Otherwise i would like to submit a patch for the above. eventually
probably even allow the setting via ethtool.

cheers,
jamal


