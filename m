From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next V2 2/3] xen-netback: avoid allocating variable
 size array on stack
Date: Thu, 2 May 2013 17:00:01 +0100
Message-ID: <20130502160001.GA23480@zion.uk.xensource.com>
References: <1367491439-27629-1-git-send-email-wei.liu2@citrix.com>
 <1367491439-27629-3-git-send-email-wei.liu2@citrix.com>
 <5182726402000078000D2A24@nat28.tlf.novell.com>
 <1367510146.21869.136.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jan Beulich <JBeulich@suse.com>, Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:17515 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759006Ab3EBQAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 12:00:03 -0400
Content-Disposition: inline
In-Reply-To: <1367510146.21869.136.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 02, 2013 at 04:55:46PM +0100, Ian Campbell wrote:
> > > +		more_data = txp->flags & XEN_NETTXF_more_data;
> > > +
> > > +		if (!drop_err)
> > > +			txp++;
> > 
> > And no need for the conditional here afaict.
> 
> I think it is needed, in the case where you've assigned txp =
> &dropped_tx you don't want to increment txp.
> 
> Or perhaps it just gets reassigned back to &dropped_tx at the top of the
> next loop, so the increment doesn't matter. Subtle! I'm happy with
> whichever way Wei prefers, but it is probably worthy of a comment
> 

Yes that's my starting point. I know that txp will always be assigned to
&dropped_tx, I just don't feel comfortable incrementing txp in that
case.

This is really a personal taste thing. :-)


Wei.
