From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] sky2: fix hard hang with netconsoling and iface going
	up
Date: Mon, 2 Feb 2009 01:38:53 +0300
Message-ID: <20090201223853.GB6567@x200.localdomain>
References: <20090127120129.GA9696@x200.localdomain> <20090127132718.GA10001@x200.localdomain> <20090129.170043.180340152.davem@davemloft.net> <20090130115907.GA22534@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:32775 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbZBAWdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 17:33:04 -0500
Received: by fg-out-1718.google.com with SMTP id 16so453324fgg.17
        for <netdev@vger.kernel.org>; Sun, 01 Feb 2009 14:33:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090130115907.GA22534@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 02:59:07PM +0300, Alexey Dobriyan wrote:
> On Thu, Jan 29, 2009 at 05:00:43PM -0800, David Miller wrote:
> > From: Alexey Dobriyan <adobriyan@gmail.com>
> > Date: Tue, 27 Jan 2009 16:27:18 +0300
> > 
> > > [PATCH] sky2: fix hard hang with netconsoling and iface going up
> > > 
> > > Printing anything over netconsole before hw is up and running is,
> > > of course, not going to work.
> > > 
> > > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> > 
> > Alexey, can you get this tested by the reporter to make sure
> > it really fixes the hang?
> 
> I'm the reporter and tester and using this patch successfully. :-)
> 
> > Once it's been tested, I'll apply it.
> 
> As for other printks, someone with 8139cp should experience the same bug.

Strangely enough, 8139cp survives with no message printed and no hang or
anything. But this is with qemu/kvm.

	static int cp_open (struct net_device *dev)
	{
	        struct cp_private *cp = netdev_priv(dev);
	        int rc;

	        if (netif_msg_ifup(cp))
	                printk(KERN_DEBUG "%s: enabling interface\n", dev->name);

	        rc = cp_alloc_rings(cp);
			...
