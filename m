From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2] xen/netfront: handle compound page fragments on
 transmit
Date: Wed, 21 Nov 2012 07:13:24 -0800
Message-ID: <1353510804.2590.38.camel@edumazet-glaptop>
References: <1353427257-16789-1-git-send-email-ian.campbell@citrix.com>
	 <1353428844.2590.17.camel@edumazet-glaptop>
	 <1353499727.13542.137.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	ANNIE LI <annie.li@oracle.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Stefan Bader <stefan.bader@canonical.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:40185 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755134Ab2KUPN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 10:13:28 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so371882iea.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 07:13:27 -0800 (PST)
In-Reply-To: <1353499727.13542.137.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-21 at 12:08 +0000, Ian Campbell wrote:
> The max-frag related limitation comes from the "wire" protocol used
> between front and back. As it stands either the frontend or the backend
> is more than likely going to drop the sort of pathalogical skbs you are
> worried.
> 
> I agree that this absolutely needs to be fixed in the protocol (and I've
> posted a call to arms on this topic on xen-devel) but I'd like to do it
> in a coordinated manner as part of a protocol extension (where the front
> and backend negotiate the maximum number of order-0 pages per Ethernet
> frame they are willing to handle) rather than as a side effect of this
> patch.
> 
> So right now I don't want to introduce frontends which default to
> sending increased numbers of pages in to the wild, since that makes
> things more complex when we come to extend the protocol.
> 
> Perhaps in the short term doing an skb_linearize when we hit this case
> would help, that will turn the pathalogical skb into a much more normal
> one. It'll be expensive but it should be rare. That assumes you can
> linearize such a large skb, which depends on the ability to allocate
> large order pages which isn't a given. Herm, maybe that doesn't work
> then.
> 

First of all, thanks a lot for all these detailed informations.

This now makes sense !


> AFAIK we don't have an existing skb_foo operation which copies an skb,
> including (or only) the frags, with the side effect of aligning and
> coalescing them. Do we?
> 

No, we only have the full linearize helper, and skb_try_coalesce()
helpers.

TCP stack uses an internal function to collapse several skbs so skbs
using a single page, I guess we could generalize this and make it
available to other uses.

Thanks !
