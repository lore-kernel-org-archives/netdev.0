From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] sc92031: sysfs link missing
Date: Thu, 3 Apr 2008 22:52:16 -0700
Message-ID: <20080403225216.4d2388cc.akpm@linux-foundation.org>
References: <bug-10380-10286@http.bugzilla.kernel.org/>
	<20080402091435.39f99428.akpm@linux-foundation.org>
	<20080402093956.2520ebfd@extreme>
	<47F5C09D.5000200@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Cesar Eduardo Barros <cesarb@cesarb.net>, tom@sharkbay.at
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47026 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960AbYDDFwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 01:52:46 -0400
In-Reply-To: <47F5C09D.5000200@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 04 Apr 2008 01:46:05 -0400 Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > Add missing sysfs device association. Compile tested only -ENOHW.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > 
> > --- a/drivers/net/sc92031.c	2008-04-02 09:34:35.000000000 -0700
> > +++ b/drivers/net/sc92031.c	2008-04-02 09:36:53.000000000 -0700
> > @@ -1446,6 +1446,7 @@ static int __devinit sc92031_probe(struc
> >  	}
> >  
> >  	pci_set_drvdata(pdev, dev);
> > +	SET_NETDEV_DEV(dev, &hw->pdev->dev);
> >  
> >  #if SC92031_USE_BAR == 0
> >  	dev->mem_start = pci_resource_start(pdev, SC92031_USE_BAR);
> 
> applied
> 

That's version 1.  There was a super-optimised version 2:



From: Stephen Hemminger <shemminger@vyatta.com>

Add missing sysfs device association. Compile tested only -ENOHW.

Addresses http://bugzilla.kernel.org/show_bug.cgi?id=10380

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: <tom@sharkbay.at>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/sc92031.c |    1 +
 1 file changed, 1 insertion(+)

diff -puN drivers/net/sc92031.c~sc92031-sysfs-link-missing drivers/net/sc92031.c
--- a/drivers/net/sc92031.c~sc92031-sysfs-link-missing
+++ a/drivers/net/sc92031.c
@@ -1446,6 +1446,7 @@ static int __devinit sc92031_probe(struc
 	}
 
 	pci_set_drvdata(pdev, dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #if SC92031_USE_BAR == 0
 	dev->mem_start = pci_resource_start(pdev, SC92031_USE_BAR);
_

