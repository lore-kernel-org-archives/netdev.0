From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3/4] tty: allow tty drivers to rename their device nodes
Date: Wed, 28 May 2014 13:56:56 -0700
Message-ID: <20140528205656.GA3117@kroah.com>
References: <cover.1400449368.git.tilman@imap.cc>
 <243519fa733359d22ce008b795f5686411e6038a.1400449372.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Paul Bolle <pebolle@tiscali.nl>,
	isdn4linux@listserv.isdn4linux.de,
	"Keil, Karsten" <isdn@linux-pingi.de>, Jiri Slaby <jslaby@suse.cz>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:40965 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbaE1UxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 16:53:21 -0400
Content-Disposition: inline
In-Reply-To: <243519fa733359d22ce008b795f5686411e6038a.1400449372.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2014 at 11:39:26PM +0200, Tilman Schmidt wrote:
> From: Paul Bolle <pebolle@tiscali.nl>
> 
> The device nodes for tty drivers are named using a straightforward
> scheme: tty_driver->name with an (increasing) digit appended. But the
> capi driver (a part of one of the current ISDN subsystems) requires a
> different naming scheme for its "capi_nc" tty_driver:
>     /dev/capi/0
>     /dev/capi/1
>     [...]

Can't you just use a '!' character to represent the '/' and the tty core
will handle it all properly for you without this tty core change needed?

> So add a devnode() callback to struct tty_driver to allow tty drivers
> to use a more elaborate naming scheme. And let tty_devnode(), the
> devnode() callback for the "tty" class, call that new callback if a tty
> driver uses one. This allows the capi driver to add a callback to
> enable its scheme.

And why the sudden need for this feature, what changed in isdn to
warrant this change?

greg k-h
