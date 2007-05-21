From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Don't enable polling in open() (was: e1000: assertion
 hit in e1000_clean(), kernel 2.6.21.1)
Date: Mon, 21 May 2007 19:42:39 -0400
Message-ID: <46522E6F.9060600@garzik.org>
References: <20070521215134.14885.84952.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, greg@suse.de,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davej@redhat.com, herbert@gondor.apana.org.au
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46432 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757490AbXEUXmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 19:42:45 -0400
In-Reply-To: <20070521215134.14885.84952.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Herbert Xu wrote:
> "netif_poll_enable can only be called if you've previously called
> netif_poll_disable.  Otherwise a poll might already be in action
> and you may get a crash like this."
> 
> Removing the call to netif_poll_enable in e1000_open should fix this issue,
> the only other call to netif_poll_enable is in e1000_up() which is only
> reached after a device reset or resume.
> 
> Bugzilla: http://bugzilla.kernel.org/show_bug.cgi?id=8455
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=240339
> 
> Tested by Doug Chapman <doug.chapman@hp.com>
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  drivers/net/e1000/e1000_main.c |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)

applied, though as a poster (DaveJ?) noted, I'm not sure it completely 
fixes the bug


