From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv3] net: Define enum for the bits used in features.
Date: Mon, 6 Jun 2011 06:58:08 +0300
Message-ID: <20110606035808.GA28858@redhat.com>
References: <1306288567-1773-1-git-send-email-maheshb@google.com>
 <1306363336-13614-1-git-send-email-maheshb@google.com>
 <20110604.133438.1450652272927306428.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: maheshb@google.com, netdev@vger.kernel.org, therbert@google.com,
	mirqus@gmail.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18206 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756035Ab1FFD5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jun 2011 23:57:54 -0400
Content-Disposition: inline
In-Reply-To: <20110604.133438.1450652272927306428.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 04, 2011 at 01:34:38PM -0700, David Miller wrote:
> From: Mahesh Bandewar <maheshb@google.com>
> Date: Wed, 25 May 2011 15:42:16 -0700
> 
> > Little bit cleanup by defining enum for all bits used. Also use those enum
> > values to redefine flags.
> > 
> > Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> > ---
> > Changes since v2:
> >  (1) Removed the include which was part of the other patch (split mishap).
> >  (2) Changed the enums to add NETIF_F_ prefix.
> 
> I hate to be a pain after you've put so much work into these patches,
> but I simply don't like this approach.
> 
> I think the abstracted interfaces should come first.  You don't need to
> change any of the NETIF_F_* defines in order to do that.  You should only
> need to add the netdev_{set,clear,test}_*() macros.
> 
> If you want you can make the "bit" argument be the flag name after the
> NETIF_F_ prefix, so "netdev_test_active_feature(dev, SG)"
> 
> Then you convert every single access.
> 
> Then you make the flags type opaque, which should at that point be a
> 6 line change at best.
> 
> And then you can implement the flags however you want.


I've been thinking about this as well. It turns out most
things above can be done with the spatch (aka coccinelle) tool.
But I think the largest problem is what to do with multiple-feature
macros such as NETIF_F_GSO_SOFTWARE.

If we keep them an 'or' of bits, we more or less commit to
an implementation that can represent them all in a single
constant.

I played with variadic macros but could not come up with something
that does not generate a lot of code.

Ideas?

-- 
MST
