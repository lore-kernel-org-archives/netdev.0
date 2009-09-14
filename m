From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Tue, 15 Sep 2009 01:03:13 +1000
Message-ID: <20090914150313.GA18560@gondor.apana.org.au>
References: <20090910125929.GA32593@redhat.com> <15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com> <20090914080923.GC14030@redhat.com> <4AADFC0A.30305@voltaire.com> <20090914091151.GE14030@redhat.com> <4AAE1026.4090702@voltaire.com> <20090914101012.GA14176@redhat.com> <4AAE4DFC.9080500@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51723 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755729AbZINPDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 11:03:22 -0400
Content-Disposition: inline
In-Reply-To: <4AAE4DFC.9080500@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2009 at 05:06:52PM +0300, Or Gerlitz wrote:
>
>> A lot of people have asked for tun support in vhost, because qemu currently uses tun.  With this scheme existing code and scripts can be used to configure both tun and bridge.  You also can utilize virtualization-specific features in tun.
> Tun has code to support some virtualization-specific features, however,  
> it has also some inherent problems, I think, for example, you don't know  
> over which NIC eventually a packet will be sent and as such, the feature  
> advertising to the guest (virtio-net) NIC is problematic, for example,  
> TSO. With vhost, since you are directly attached to a NIC and assuming  
> its a PF or VF NIC and not something like macvlan/veth you can actually  
> know what features are supported by this NIC.

TSO is not a problem because we provide a software fallback when
the hardware does not support it.  So guests should always enable
TSO if they support it and not worry about the physical NIC.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
