From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BUG] drivers/net/ioc3_eth.c in 2.5
Date: Mon, 9 Jun 2003 11:08:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609110855.2e264ce1.shemminger@osdl.org>
References: <20030606161658.1f01b8f9.shemminger@osdl.org>
	<20030607.013010.116359540.davem@redhat.com>
	<20030609101018.0ca2e1f9.shemminger@osdl.org>
	<20030609171224.GA14623@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, ralf@oss.sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030609171224.GA14623@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 9 Jun 2003 13:12:24 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> On Mon, Jun 09, 2003 at 10:10:18AM -0700, Stephen Hemminger wrote:
> > Looks like the right fix is:
> > --- ioc3-eth.c.orig	2003-06-09 10:05:45.000000000 -0700
> > +++ ioc3-eth.c	2003-06-09 10:04:45.000000000 -0700
> > @@ -1614,6 +1614,7 @@ static void __devexit ioc3_remove_one (s
> >  	struct ioc3 *ioc3 = ip->regs;
> >  
> >  	iounmap(ioc3);
> > +	unregister_netdev(dev);
> >  	pci_release_regions(pdev);
> >  	kfree(dev);
> >  }
> 
> You want to unregister before iounmap.
> 
> 	Jeff
> 
> 
Okay:
--- ioc3-eth.c.orig	2003-06-09 10:05:45.000000000 -0700
+++ ioc3-eth.c	2003-06-09 11:08:01.000000000 -0700
@@ -1613,6 +1613,7 @@ static void __devexit ioc3_remove_one (s
 	struct ioc3_private *ip = dev->priv;
 	struct ioc3 *ioc3 = ip->regs;
 
+	unregister_netdev(dev);
 	iounmap(ioc3);
 	pci_release_regions(pdev);
 	kfree(dev);
