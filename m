From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: [PATCH v2 net 2/2] tg3: Fix data corruption on 5725 with
 TSO
Date: Wed, 15 May 2013 08:12:34 -0700
Message-ID: <1368630754.3768.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
 <1368479056-11780-3-git-send-email-nsujir@broadcom.com>
 <1368479644.13473.121.camel@edumazet-glaptop>
 <51915C7D.2000407@broadcom.com>
 <1368481224.13473.124.camel@edumazet-glaptop>
 <51915F77.5000405@broadcom.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7236@saturn3.aculab.com>
 <1368543869.12268.49.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7237@saturn3.aculab.com>
 <1368548345.12268.76.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7239@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1659 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756602Ab3EOPMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 11:12:43 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7239@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-15 at 09:56 +0100, David Laight wrote: 
> > > If the 'fix' is to relocate the skb you are doomed to lose regardless
> > > of the check - unless you are willing to reallocate a lot of times,
> > > and without freeing the old skb.
> > > I'd assumed the 'fix' was to disable the relevant offload.
> > 
> > We relocate once and then drop the packet if we encounter additional
> > errors, including OOM, DMA mapping error, 4G boundary, etc.  The new
> > linear skb should not hit the 4G boundary again.  The room between the
> > end of this current buffer and 4G isn't big enough for the new linear
> > skb.
> 
> The first skb might be just below the 4G boundary and the
> second just below the 8G one.
> 

We will discard the packet if that happens.  I think the probabilty is
very small.
