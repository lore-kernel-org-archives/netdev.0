From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] CONFIG_PM=n slim: drivers/net/*
Date: Sat, 12 Aug 2006 10:06:29 -0700
Message-ID: <adar6zlnasq.fsf@cisco.com>
References: <20060812004623.GM6847@martell.zuzino.mipt.ru>
	<20060811184943.96419537.akpm@osdl.org>
	<20060812023014.GP6847@martell.zuzino.mipt.ru>
	<20060811194952.9d664698.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:13632 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S964916AbWHLRGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 13:06:32 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060811194952.9d664698.akpm@osdl.org> (Andrew Morton's message of "Fri, 11 Aug 2006 19:49:52 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > Also this won't allow
 > > 
 > > 	struct pci_driver {
 > > 		...
 > > 	#ifdef CONFIG_PM
 > > 		int (*suspend)(...);
 > > 		int (*resume)(...);
 > > 	#endif
 > > 		...
 > > 	};
 > > 
 > > which is good for a) space savings in CONFIG_PM=n case, and
 > > b) making drivers care about CONFIG_PM=n users hard way aka compilation
 > > failure.
 > 
 > eh?  Both versions will generate identical code.

I think his point was that by #ifdef-ing out the assignment to
.suspend/.resume, then the actual suspend/resume members of struct
pci_driver could be removed in the CONFIG_PM=n case -- which would
shrink sizeof (struct pci_driver).

 - R.
