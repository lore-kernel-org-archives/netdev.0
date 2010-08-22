From: David Miller <davem@davemloft.net>
Subject: Re: IPsec: Why do pfkey_getspi and xfrm_alloc_userspi call
 xfrm_find_acq_byseq?
Date: Sun, 22 Aug 2010 00:53:53 -0700 (PDT)
Message-ID: <20100822.005353.260099324.davem@davemloft.net>
References: <4C6D29B9.5070403@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christophe.gouault@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50927
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751896Ab0HVHxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 03:53:44 -0400
In-Reply-To: <4C6D29B9.5070403@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe Gouault <christophe.gouault@6wind.com>
Date: Thu, 19 Aug 2010 14:55:21 +0200

> The call to xfrm_find_acq_byseq() by the pfkey_getspi() and
> xfrm_alloc_userspi() functions is quite costly and proves to entail
> scalability issues when performing thousands of IKE negotiations with
> racoon (from ipsec-tools distribution) or charon (from strongswan
> distribution).
> 
> Removing this call in the kernel drastically accelerates the
> processing and does not seem to entail functional problems.
> 
> For now, I don't see the point of this call. I need to understand its
> purpose, because I'm highly tempted to simply remove it.

First of all, removing a function because you don't understand
why it's there is rarely a good idea :-)

I think the semantics require that we check for existing ACQUIRE
state entries before we allocate an SPI.

The likelyhood of breaking something if you remove the call is very
high.

