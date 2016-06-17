From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] IPsec NAT-T issue
Date: Fri, 17 Jun 2016 12:24:29 +0200
Message-ID: <20160617102429.GH7698@gauss.secunet.com>
References: <20160612234814.15460-1-blair.steven@alliedtelesis.co.nz>
 <20160613102024.GX7698@gauss.secunet.com>
 <5760A501.3070504@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Blair Steven <Blair.Steven@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37207 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751309AbcFQKYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 06:24:33 -0400
Content-Disposition: inline
In-Reply-To: <5760A501.3070504@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 12:44:54AM +0000, Blair Steven wrote:
> The restoration is happening - but being actioned on the wrong location.
> 
> The destination IP address is being saved and restored, and the SPI 
> being written directly after the destination IP address. From my 
> understanding though, the ESN shuffling should have saved and restored 
> the UDP source / dest ports + SPI.

Yes, looks like we copy with a wrong offset if udp encapsulation
is used, skb_transport_header() does not point to the esp header
in this case. Ccing Herbert, he changed this part when switching
to the new AEAD interface with
commit 7021b2e1cddd ("esp4: Switch to new AEAD interface").

> 
> -Blair
> 
> On 06/13/2016 10:20 PM, Steffen Klassert wrote:
> > On Mon, Jun 13, 2016 at 11:48:13AM +1200, Blair Steven wrote:
> >> During testing we have discovered an issue with IPsec NAT-T where the SPI
> >> is over writing the source and dest ports of the UDP header.
> > The headers should be restored after the crypto operation in
> > esp_restore_header(). Does this not happen in your case? What
> > kind of problem do you experience?
> >
