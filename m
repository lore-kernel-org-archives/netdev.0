From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] net: forcedeth use pci_choose_state instead of PCI_D3hot - v2
Date: Tue, 19 Aug 2008 19:58:44 +0200
Message-ID: <200808191958.45886.rjw@sisk.pl>
References: <1218954333-12819-1-git-send-email-yhlu.kernel@gmail.com> <200808190008.54743.rjw@sisk.pl> <48A9FAD8.9000503@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yhlu.kernel@gmail.com>,
	Jeff Garzik <jgarzik@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:53820 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752913AbYHSRzc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 13:55:32 -0400
In-Reply-To: <48A9FAD8.9000503@simon.arlott.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, 19 of August 2008, Simon Arlott wrote:
> On 18/08/08 23:08, Rafael J. Wysocki wrote:
> > On Monday, 18 of August 2008, Yinghai Lu wrote:
> >> On Mon, Aug 18, 2008 at 3:22 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> >> 
> >> >> > >  drivers/net/forcedeth.c |    8 +++++---
> >> >> > >  1 file changed, 5 insertions(+), 3 deletions(-)
> >> >> > >
> >> >> > > Index: linux-2.6/drivers/net/forcedeth.c
> >> >> > > ===================================================================
> >> >> > > --- linux-2.6.orig/drivers/net/forcedeth.c
> >> >> > > +++ linux-2.6/drivers/net/forcedeth.c
> >> >> > > @@ -5975,10 +5975,12 @@ static void nv_shutdown(struct pci_dev *
> >> >> > >        if (netif_running(dev))
> >> >> > >                nv_close(dev);
> >> >> > >
> >> >> > > -       pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> >> >> > > -       pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
> >> >> > >        pci_disable_device(pdev);
> >> >> > > -       pci_set_power_state(pdev, PCI_D3hot);
> >> >> > > +       if (system_state == SYSTEM_POWER_OFF) {
> >> >> > > +               if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
> >> >> > > +                       pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> >> >> > > +               pci_set_power_state(pdev, PCI_D3hot);
> >> >> > > +       }
> >> >> > >  }
> >> >> > >  #else
> >> >> > >  #define nv_suspend NULL
> >> >> > >
> >> >> >
> >> 
> >> > Does the last patch work for you BTW?
> >> >
> >> 
> >> it works.
> > 
> > OK, thanks for testing.
> > 
> > I think we can use it as a quick fix for 2.6.27.  Do you agree?
> > 
> > Still, it would be helpful to verify if this is the same MSI issue reported by
> > Simon.
> 
> I tried to test that patch but even without it standby/resume has stopped working:

Which kernel is this?

> http://img89.imageshack.us/img89/1861/1005552wb5.jpg (standby, tainted)
> http://img89.imageshack.us/img89/5409/1005561ys2.jpg (resume)
> http://img503.imageshack.us/img503/8720/1005571bc0.jpg (resume)
> http://img135.imageshack.us/img135/5048/1005572be3.jpg (standby)

Rafael
