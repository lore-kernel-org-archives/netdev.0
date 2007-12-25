From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] via-velocity big-endian support
Date: Tue, 25 Dec 2007 22:56:06 +0000
Message-ID: <20071225225606.GC27894@ZenIV.linux.org.uk>
References: <20071224050659.GS8181@ftp.linux.org.uk> <20071225224333.GA21585@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ftp.linux.org.uk>, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34301 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbXLYW4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 17:56:11 -0500
Content-Disposition: inline
In-Reply-To: <20071225224333.GA21585@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 25, 2007 at 11:43:33PM +0100, Francois Romieu wrote:
> > +#define DESC_OWNER cpu_to_le16(0x8000)
> > +
> 
> DESC_OWNER does not seem to be used.

*nod*
That should be removed.
 
> [...]
> > +enum {
> > +	RX_INTEN = __constant_cpu_to_le16(0x8000)
> > +};
> 
> Can we avoid using cpu_to_leXY here for consistency sake within the driver
> (and among different drivers as well) ?

???

What is the problem with having such constants?  If you mean "could we
use cpu_to_le16() instead of __constant_cpu_to_le16()", the answer's
no - that's one of the very few places where __constant_.... form is
needed (other are case <...>: and initializers for non-auto variables).
