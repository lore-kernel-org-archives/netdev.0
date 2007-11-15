From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 2/2] move unneeded data to initdata section
Date: Thu, 15 Nov 2007 16:14:29 +0100
Message-ID: <20071115151429.GC22825@uranus.ravnborg.org>
References: <20071107120100.GA10185@iris.sw.ru> <m1abpfy3xz.fsf@ebiederm.dsl.xmission.com> <473C5ABC.5090204@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	containers@lists.osdl.org, netdev@vger.kernel.org, clg@fr.ibm.com,
	benjamin.thery@bull.net
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:50371 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756488AbXKOPNE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 10:13:04 -0500
Content-Disposition: inline
In-Reply-To: <473C5ABC.5090204@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 15, 2007 at 05:42:04PM +0300, Denis V. Lunev wrote:
> Eric W. Biederman wrote:
> > "Denis V. Lunev" <den@openvz.org> writes:
> > 
> >> This patch reverts Eric's commit 2b008b0a8e96b726c603c5e1a5a7a509b5f61e35
> >>
> >> It diets .text & .data section of the kernel if CONFIG_NET_NS is not set.
> >> This is safe after list operations cleanup.
> > 
> > Ok.  This patch is technically safe because none of the touched
> > code can live in a module and so we never touch the exit code path.
> > 
> > However in the general case and as a code idiom this __net_initdata
> > on struct pernet_operations is fundamentally horribly broken.
> > 
> > Look at what happens if we use this idiom in module.  There
> > is only one definition of __initdata ".init.data".  The module
> > loader places all sections that begin with .init in a region of
> > memory that will be discarded after module initialization.  
> 
> nothing is discarded after module load. Though, I can be wrong. Could
> you point me to the exact place?
If __initdata is not discarded after module load then we should do it.
There is no reason to waste __initdata RAM when the module is loaded.

	Sam
