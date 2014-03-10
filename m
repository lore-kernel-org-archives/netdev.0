From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/5] skbuff: skb_segment: orphan frags before copying
Date: Tue, 11 Mar 2014 06:12:23 +0800
Message-ID: <20140310221223.GA15839@gondor.apana.org.au>
References: <1394468807-25980-1-git-send-email-mst@redhat.com>
 <1394468807-25980-6-git-send-email-mst@redhat.com>
 <20140310213404.GB15352@gondor.apana.org.au>
 <20140310215236.GA7052@redhat.com>
 <20140310215640.GA15684@gondor.apana.org.au>
 <20140310220717.GA7150@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jbenc@redhat.com,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Simon Horman <horms@verge.net.au>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Thomas Graf <tgraf@suug.ch>, Miklos Szeredi <mszeredi@suse.cz>,
	=?us-ascii?B?PT9VVEYtOD9xP1BldGVyPTIwUGFuPTI4PUU2PUJEPTk4PUU1PThEPUFC?=
	 =?us-ascii?B?PUU1PUI5PUIzPTI5Pz0=?= <panweiping3@gmail.com>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:49100 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbaCJWMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 18:12:41 -0400
Content-Disposition: inline
In-Reply-To: <20140310220717.GA7150@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 12:07:17AM +0200, Michael S. Tsirkin wrote:
> 
> Once one skb completes the callback is invoked and userspace
> reuses this buffer for something else.
> At that point it's too late to do the copy.

OK, would it be possible to delay the callback until all generated
skbs are completed?

> > IOW if we pass along SKBTX_SHARED_FRAG will it work?
> 
> I don't see how would SKBTX_SHARED_FRAG help with this at all.
> That only works for pages gifted to kernel by e.g. vmsplice
> that aren't reused by userspace.

Sorry cut-n-paste error, I meant SKBTX_DEV_ZEROCOPY.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
