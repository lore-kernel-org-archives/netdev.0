From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next 2/2] xfrm: configure policy hash table
 thresholds by /proc
Date: Thu, 22 May 2014 12:09:05 +0200
Message-ID: <20140522100905.GH32371@secunet.com>
References: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
 <1399902325-1788-3-git-send-email-christophe.gouault@6wind.com>
 <20140515083447.GC32371@secunet.com>
 <5379B591.6020001@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46643 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753198AbaEVKJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 06:09:16 -0400
Content-Disposition: inline
In-Reply-To: <5379B591.6020001@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 19, 2014 at 09:41:05AM +0200, Christophe Gouault wrote:
> On 05/15/2014 10:34 AM, Steffen Klassert wrote:
> 
> >Second, on the long run we have to remove the IPsec flowcache
> >as this has the same limitation as our routing cache had.
> >To do this, we need to replace the hashlist based policy and
> >state lookups by a well performing lookup algorithm and I
> >would like to do that without any user visible changes.
> 
> Efficient lookup is a field we have studied for long in my company.
> There are many thesis about multi-field classification, but none enables
> to cover all use cases. All suffer from limitations (building time,
> memory consumption, number of fields, time and memory
> unpredictability...) and each is adapted to a specific use case.

Right, it is even hard to find a algorithm that covers the most
common usecases. That's why we still use this list + flowcache
based lookup mechanism. But on the long run we need an option
to disable/remove the flowcache without loosing to much performance
in the fastpath lookup.

Like the ipv4 routing cache that was removed recently, the IPsec
flowcache gets its performance from the network traffic that
arrives and therefore it might be partly controllable by remote
entities. This can be critical for a security protocol like IPsec.

> 
> Exporting a userland API (here by /proc) enables a user or a daemon to
> choose a strategy according to information the kernel does not
> necessarily have, and enables to implement various (possibly complex)
> policies.
> 

If we add a user API for the current lookup mechanism, we will stick
with this because we can't change it anymore without breaking userspace.
So I don't want to add one before we finally decided on a long term
lookup mechanism for IPsec.
