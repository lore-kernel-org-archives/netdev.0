From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: skb_segment() questions
Date: Mon, 30 Mar 2009 09:50:45 +0100
Message-ID: <1238403045.854.39.camel@blaa>
References: <f0ed9b110903041912v6fba381fm4da792d49b1cbb91@mail.gmail.com>
	 <20090329020701.GA9983@gondor.apana.org.au>
	 <20090328.233929.160905643.davem@davemloft.net>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jamesclhuang@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48405 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756778AbZC3Iu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2009 04:50:58 -0400
In-Reply-To: <20090328.233929.160905643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-03-28 at 23:39 -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sun, 29 Mar 2009 10:07:01 +0800
> 
> > gso: Fix support for linear packets
> > 
> > When GRO/frag_list support was added to GSO, I made an error
> > which broke the support for segmenting linear GSO packets (GSO
> > packets are normally non-linear in the payload).
> > 
> > These days most of these packets are constructed by the tun
> > driver, which prefers to allocate linear memory if possible.
> > This is fixed in the latest kernel, but for 2.6.29 and earlier
> > it is still the norm.
> > 
> > Therefore this bug causes failures with GSO when used with tun
> > in 2.6.29.
> > 
> > Reported-by: James Huang <jamesclhuang@gmail.com>
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied, thanks.

This is needed in -stable too, fwiw. Fixes e.g. virtio guest->remote
with 2.6.29 host:

  https://bugzilla.redhat.com/490266

Cheers,
Mark.

