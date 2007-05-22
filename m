From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [PATCH] e1000: Don't enable polling in open() (was: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1)
Date: Tue, 22 May 2007 10:49:21 +1000
Message-ID: <20070522004921.GA8130@gondor.apana.org.au>
References: <20070521215134.14885.84952.stgit@localhost.localdomain> <20070521221635.GA16888@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Auke Kok <auke-jan.h.kok@intel.com>, jeff@garzik.org,
	stable@vger.kernel.org, greg@suse.de,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1787 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756034AbXEVAtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 20:49:45 -0400
Content-Disposition: inline
In-Reply-To: <20070521221635.GA16888@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 21, 2007 at 06:16:35PM -0400, Dave Jones wrote:
> On Mon, May 21, 2007 at 02:51:35PM -0700, Auke Kok wrote:
>  > Herbert Xu wrote:
>  > "netif_poll_enable can only be called if you've previously called
>  > netif_poll_disable.  Otherwise a poll might already be in action
>  > and you may get a crash like this."
>  > 
>  > Removing the call to netif_poll_enable in e1000_open should fix this issue,
>  > the only other call to netif_poll_enable is in e1000_up() which is only
>  > reached after a device reset or resume.
>  > 
>  > Bugzilla: http://bugzilla.kernel.org/show_bug.cgi?id=8455
>  > https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=240339
> 
> This probably doesn't solve the latter bug.
> The code you reference isn't there in the kernel tested in that bug
> (2.6.21)   In 2.6.21, netif_poll_enable is only called from
> e1000_up(), not e1000_open()

Yes we need a different fix for 2.6.21.  There e1000_open calls
e1000_up which is why we still get the netif_poll_enable.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
