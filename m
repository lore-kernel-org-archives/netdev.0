From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv3] net: Define enum for the bits used in features.
Date: Mon, 6 Jun 2011 18:32:53 +0300
Message-ID: <20110606153253.GB30665@redhat.com>
References: <1306363336-13614-1-git-send-email-maheshb@google.com>
 <20110604.133438.1450652272927306428.davem@davemloft.net>
 <20110606035808.GA28858@redhat.com>
 <20110605.221537.899061768025493519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: maheshb@google.com, netdev@vger.kernel.org, therbert@google.com,
	mirqus@gmail.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55947 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757256Ab1FFPck (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 11:32:40 -0400
Content-Disposition: inline
In-Reply-To: <20110605.221537.899061768025493519.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 05, 2011 at 10:15:37PM -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Mon, 6 Jun 2011 06:58:08 +0300
> 
> > I've been thinking about this as well. It turns out most
> > things above can be done with the spatch (aka coccinelle) tool.
> > But I think the largest problem is what to do with multiple-feature
> > macros such as NETIF_F_GSO_SOFTWARE.
> > 
> > If we keep them an 'or' of bits, we more or less commit to
> > an implementation that can represent them all in a single
> > constant.
> > 
> > I played with variadic macros but could not come up with something
> > that does not generate a lot of code.
> 
> Since the GSO accessors deal with mutliple bits, you can create
> special GSO specific interfaces to manipulate them.

Yes but it's not just GSO.
It's anything that includes more than 1 feature.
Examples:
NETIF_F_ALL_CSUM
NETIF_F_ALL_TX_OFFLOADS
NETIF_F_V6_CSUM
NETIF_F_SOFT_FEATURES

etc

Creating many accessors for each will need a lot
of code duplication ...

-- 
MST
