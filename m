From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/5] skbuff: skb_segment: orphan frags before copying
Date: Tue, 11 Mar 2014 05:34:05 +0800
Message-ID: <20140310213404.GB15352@gondor.apana.org.au>
References: <1394468807-25980-1-git-send-email-mst@redhat.com>
 <1394468807-25980-6-git-send-email-mst@redhat.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394468807-25980-6-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 10, 2014 at 06:29:36PM +0200, Michael S. Tsirkin wrote:
> skb_segment copies frags around, so we need
> to copy them carefully to avoid accessing
> user memory after reporting completion to userspace
> through a callback.
> 
> skb_segment doesn't normally happen on datapath:
> TSO needs to be disabled - so disabling zero copy
> in this case does not look like a big deal.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Why do we need this patch at all? Contrary to what you said,
this path is definitely performance-critical since the basis
of being able to enable GSO by default is that it causes no
regressions in non-TSO cases.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
