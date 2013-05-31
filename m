From: Simon Horman <horms@verge.net.au>
Subject: Re: [Patch net-next v3] net: clean up skb headers code
Date: Fri, 31 May 2013 09:18:41 +0900
Message-ID: <20130531001841.GB26684@verge.net.au>
References: <1369879575-18701-1-git-send-email-amwang@redhat.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7258@saturn3.aculab.com>
 <20130530.131603.1155012584617016387.davem@davemloft.net>
 <1369947918.2414.28.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	amwang@redhat.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:40512 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442Ab3EaAR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 20:17:57 -0400
Content-Disposition: inline
In-Reply-To: <1369947918.2414.28.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 10:05:18PM +0100, Ben Hutchings wrote:
> On Thu, 2013-05-30 at 13:16 -0700, David Miller wrote:
> > From: "David Laight" <David.Laight@ACULAB.COM>
> > Date: Thu, 30 May 2013 12:18:13 +0100
> > 
> > >> commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
> > >> fields of struct skbuff) converts skb->*_header to u16,
> > >> some #if NET_SKBUFF_DATA_USES_OFFSET are now useless,
> > >> and to be safe, we could just use "X = ~(typeof(X))0;"
> > >> as suggested by David and Ben.
> > > 
> > > IIRC ~(unsigned short)0 is the same as ~0 and will be -1.
> > > define an actual constant with value 0xffff
> > 
> > The problem with doing that is that if this type is changed again,
> > we'lll go through this same circus changing the constant everywhere
> > and missing some cases.
> > 
> > I absolutely want to see a version of this fix that makes sure that if
> > the type changes, either the constantly automatically change (that's
> > the "typeof(X)" approach) or the build breaks spectacularly until the
> > value is fixed up.
> 
> Let's just give the 'invalid' value a name and define it right next to
> those fields.  It might be worth reintroducing sk_buff_data_t too, since
> there was at least one place which wanted to save and restore offsets in
> local variables.

sk_buff_data_t was not removed, its just used for less fields.
