From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] net: forcedeth use pci_choose_state instead of PCI_D3hot - v2
Date: Tue, 19 Aug 2008 00:08:53 +0200
Message-ID: <200808190008.54743.rjw@sisk.pl>
References: <1218954333-12819-1-git-send-email-yhlu.kernel@gmail.com> <200808181222.49576.rjw@sisk.pl> <86802c440808181450y5e908b6eo3e6d54bfca6f2d8f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@redhat.com>, "Ingo Molnar" <mingo@elte.hu>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	"Jesse Barnes" <jbarnes@virtuousgeek.org>,
	Simon Arlott <simon@fire.lp0.eu>
To: "Yinghai Lu" <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:47814 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754867AbYHRWFm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2008 18:05:42 -0400
In-Reply-To: <86802c440808181450y5e908b6eo3e6d54bfca6f2d8f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 18 of August 2008, Yinghai Lu wrote:
> On Mon, Aug 18, 2008 at 3:22 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> 
> >> > >  drivers/net/forcedeth.c |    8 +++++---
> >> > >  1 file changed, 5 insertions(+), 3 deletions(-)
> >> > >
> >> > > Index: linux-2.6/drivers/net/forcedeth.c
> >> > > ===================================================================
> >> > > --- linux-2.6.orig/drivers/net/forcedeth.c
> >> > > +++ linux-2.6/drivers/net/forcedeth.c
> >> > > @@ -5975,10 +5975,12 @@ static void nv_shutdown(struct pci_dev *
> >> > >        if (netif_running(dev))
> >> > >                nv_close(dev);
> >> > >
> >> > > -       pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> >> > > -       pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
> >> > >        pci_disable_device(pdev);
> >> > > -       pci_set_power_state(pdev, PCI_D3hot);
> >> > > +       if (system_state == SYSTEM_POWER_OFF) {
> >> > > +               if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
> >> > > +                       pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> >> > > +               pci_set_power_state(pdev, PCI_D3hot);
> >> > > +       }
> >> > >  }
> >> > >  #else
> >> > >  #define nv_suspend NULL
> >> > >
> >> >
> 
> > Does the last patch work for you BTW?
> >
> 
> it works.

OK, thanks for testing.

I think we can use it as a quick fix for 2.6.27.  Do you agree?

Still, it would be helpful to verify if this is the same MSI issue reported by
Simon.

Thanks,
Rafael
