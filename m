From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH v6] xen network backend driver
Date: Wed, 16 Mar 2011 09:17:25 +0000
Message-ID: <1300267045.17339.2365.camel@zakaz.uk.xensource.com>
References: <1300183578.17339.2239.camel@zakaz.uk.xensource.com>
	 <20110315.193855.104049587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"jeremy@goop.org" <jeremy@goop.org>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"mirqus@gmail.com" <mirqus@gmail.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:60745 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295Ab1CPJR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 05:17:27 -0400
In-Reply-To: <20110315.193855.104049587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-16 at 02:38 +0000, David Miller wrote:
> From: Ian Campbell <Ian.Campbell@citrix.com>
> Date: Tue, 15 Mar 2011 10:06:18 +0000
> 
> > netback is the host side counterpart to the frontend driver in
> > drivers/net/xen-netfront.c. The PV protocol is also implemented by
> > frontend drivers in other OSes too, such as the BSDs and even Windows.
> > 
> > The patch is based on the driver from the xen.git pvops kernel tree but
> > has been put through the checkpatch.pl wringer plus several manual
> > cleanup passes and review iterations. The driver has been moved from
> > drivers/xen/netback to drivers/net/xen-netback.
> > 
> > One major change from xen.git is that the guest transmit path (i.e. what
> > looks like receive to netback) has been significantly reworked to remove
> > the dependency on the out of tree PageForeign page flag (a core kernel
> > patch which enables a per page destructor callback on the final
> > put_page). This page flag was used in order to implement a grant map
> > based transmit path (where guest pages are mapped directly into SKB
> > frags). Instead this version of netback uses grant copy operations into
> > regular memory belonging to the backend domain. Reinstating the grant
> > map functionality is something which I would like to revisit in the
> > future.
> > 
> > Note that this driver depends on 2e820f58f7ad "xen/irq: implement
> > bind_interdomain_evtchn_to_irqhandler for backend drivers" which is in
> > linux next via the "xen-two" tree and is intended for the 2.6.39 merge
> > window:
> >         git://git.kernel.org/pub/scm/linux/kernel/git/konrad/xen.git stable/backends
> > this branch has only that single commit since 2.6.38-rc2 and is safe for
> > cross merging into the net branch.
> > 
> > Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> > Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Ok, I merged that xen commit into my tree and then added this
> driver.

Awesome, thanks!

For the ML archives: the history which led to this patch was
2e820f58f7ad..db3afbafeffd which I have pushed to:
        git://xenbits.xen.org/people/ianc/linux-2.6.git upstream/dom0/backend/netback-history
        
The base of the cleanup/upstreaming work (i.e. the commit which
corresponds to xen.git 072407c789a0) is
        git://xenbits.xen.org/people/ianc/linux-2.6.git upstream/dom0/backend/netback-history-base
        
Ian.

