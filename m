From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Revert "net: Reset secmark when scrubbing packet"
Date: Thu, 16 Apr 2015 09:32:09 +0100
Message-ID: <20150416083209.GD32170@casper.infradead.org>
References: <20150415100107.GA3655@gondor.apana.org.au>
 <552E3B7A.2040701@6wind.com>
 <20150415102229.GA3917@gondor.apana.org.au>
 <20150415135739.GA5534@gondor.apana.org.au>
 <552E86A6.9000101@6wind.com>
 <20150416010326.GA10864@gondor.apana.org.au>
 <alpine.LRH.2.11.1504161700130.23392@namei.org>
 <20150416081253.GA13595@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@namei.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-security-module@vger.kernel.org,
	Flavio Leitner <fbl@sysclose.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150416081253.GA13595@gondor.apana.org.au>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/16/15 at 04:12pm, Herbert Xu wrote:
> On Thu, Apr 16, 2015 at 05:02:15PM +1000, James Morris wrote:
> > 
> > They don't support namespaces, and maintaining the label is critical for 
> > SELinux, at least, which mediates security for the system as a whole.
> 
> Thanks for the confirmation James, I thought this looked a bit
> dodgy :)
> 
> ---8<---
> This patch reverts commit b8fb4e0648a2ab3734140342002f68fb0c7d1602
> because the secmark must be preserved even when a packet crosses
> namespace boundaries.  The reason is that security labels apply to
> the system as a whole and is not per-namespace.

No objection to reverting, _BUT_ just because security labels
apply to the system as a whole does not mean that both the packet
in the underlay and overlay belong to the same context.

The point here was to not blindly inherit the security context of a
packet based on the outer or inner header. Someone tagging all
packets addressed to the host itself with a SElinux context may not
expect that SELinux context to be preserved into a namespaced tenant.
