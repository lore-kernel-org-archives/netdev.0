From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 11:12:44 +0800
Message-ID: <20080929031244.GA22619@gondor.apana.org.au>
References: <20080928211530.GA9341@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52546 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751171AbYI2DMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2008 23:12:54 -0400
Content-Disposition: inline
In-Reply-To: <20080928211530.GA9341@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 01:15:30AM +0400, Evgeniy Polyakov wrote:
>
> Idea is rather trivial: disable TSO and GSO on loopback. The latter was

Weird.  That's the very first thing I tried but for me it goes
the other way.

With TSO/GSO:

Throughput 169.19 MB/sec 1 procs

Without:

Throughput 24.0079 MB/sec 1 procs

Note that I only disabled TSO/GSO using ethtool:

etch1:~# ethtool -k lo
Offload parameters for lo:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off
etch1:~# 

Can you see if reverting the patch but using ethtool gives you the
same results?

PS I'm using FV Xen.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
