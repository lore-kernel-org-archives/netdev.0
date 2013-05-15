From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net 2/2] tg3: Fix data corruption on 5725 with TSO
Date: Wed, 15 May 2013 09:56:25 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7239@saturn3.aculab.com>
References: <1368479056-11780-1-git-send-email-nsujir@broadcom.com> <1368479056-11780-3-git-send-email-nsujir@broadcom.com> <1368479644.13473.121.camel@edumazet-glaptop> <51915C7D.2000407@broadcom.com> <1368481224.13473.124.camel@edumazet-glaptop> <51915F77.5000405@broadcom.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7236@saturn3.aculab.com> <1368543869.12268.49.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7237@saturn3.aculab.com> <1368548345.12268.76.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42171 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752229Ab3EOI57 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 04:57:59 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26932-01 for <netdev@vger.kernel.org>;
 Wed, 15 May 2013 09:57:56 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1368548345.12268.76.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > If the 'fix' is to relocate the skb you are doomed to lose regardless
> > of the check - unless you are willing to reallocate a lot of times,
> > and without freeing the old skb.
> > I'd assumed the 'fix' was to disable the relevant offload.
> 
> We relocate once and then drop the packet if we encounter additional
> errors, including OOM, DMA mapping error, 4G boundary, etc.  The new
> linear skb should not hit the 4G boundary again.  The room between the
> end of this current buffer and 4G isn't big enough for the new linear
> skb.

The first skb might be just below the 4G boundary and the
second just below the 8G one.

	David
