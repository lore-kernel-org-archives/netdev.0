From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs [2nd try]
Date: Thu, 19 Jun 2008 14:50:09 -0700
Message-ID: <20080619145009.5b24f028@extreme>
References: <cover.1213898165.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Kieran Mansley <kmansley@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:42946 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598AbYFSVuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 17:50:16 -0400
In-Reply-To: <cover.1213898165.git.bhutchings@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jun 2008 19:44:56 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> [Re-sent with the correct Message-ID, previously eaten by mutt.]
> 
> Large Receive Offload (LRO) destroys packet headers that should be
> preserved when forwarding.  Currently it also triggers a BUG() or WARN()
> in skb_gso_segment().  We should disable it wherever forwarding is
> enabled, and discard LRO skbs with a warning if it is turned back on.
> 
> Since the previous version of these patches, I have:
> - Tightened the test for LRO'd skbs, so it should not catch skbs from
>   VM guests that want GSO
> - Made the test an inline function, with the warning a separate extern
>   function
> - Rebased against net-next-2.6
> 

I like that it covers both cases and looks clean. If anyone ever gets
around to rewriting the network device driver chapter in the linux
kernel book(s) this should be covered in more detail.
