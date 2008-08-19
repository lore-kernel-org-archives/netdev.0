From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [PATCH] net: forcedeth use pci_choose_state instead of PCI_D3hot
 - v2
Date: Tue, 19 Aug 2008 19:33:06 +0100
Message-ID: <48AB11E2.3040705@simon.arlott.org.uk>
References: <1218954333-12819-1-git-send-email-yhlu.kernel@gmail.com> <200808190008.54743.rjw@sisk.pl> <48A9FAD8.9000503@simon.arlott.org.uk> <200808191958.45886.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yhlu.kernel@gmail.com>,
	Jeff Garzik <jgarzik@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753074AbYHSSd7@vger.kernel.org>
In-Reply-To: <200808191958.45886.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/08/08 18:58, Rafael J. Wysocki wrote:
> On Tuesday, 19 of August 2008, Simon Arlott wrote:
>> On 18/08/08 23:08, Rafael J. Wysocki wrote:
>> > On Monday, 18 of August 2008, Yinghai Lu wrote:
>> >> On Mon, Aug 18, 2008 at 3:22 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>> >> 
>> >> >> > >  drivers/net/forcedeth.c |    8 +++++---
>> >> >> > >  1 file changed, 5 insertions(+), 3 deletions(-)
>> >> >> > >
>> >> >> > > Index: linux-2.6/drivers/net/forcedeth.c
>> >> >> > > ===================================================================
>> >> >> > > --- linux-2.6.orig/drivers/net/forcedeth.c
>> >> >> > > +++ linux-2.6/drivers/net/forcedeth.c
>> >> >> > > @@ -5975,10 +5975,12 @@ static void nv_shutdown(struct pci_dev *
>> >> >> > >        if (netif_running(dev))
>> >> >> > >                nv_close(dev);
>> >> >> > >
>> >> >> > > -       pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
>> >> >> > > -       pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
>> >> >> > >        pci_disable_device(pdev);
>> >> >> > > -       pci_set_power_state(pdev, PCI_D3hot);
>> >> >> > > +       if (system_state == SYSTEM_POWER_OFF) {
>> >> >> > > +               if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
>> >> >> > > +                       pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
>> >> >> > > +               pci_set_power_state(pdev, PCI_D3hot);
>> >> >> > > +       }
>> >> >> > >  }
>> >> >> > >  #else
>> >> >> > >  #define nv_suspend NULL
>> >> >> > >
>> >> >> >
>> >> 
>> >> > Does the last patch work for you BTW?
>> >> >
>> >> 
>> >> it works.
>> > 
>> > OK, thanks for testing.
>> > 
>> > I think we can use it as a quick fix for 2.6.27.  Do you agree?
>> > 
>> > Still, it would be helpful to verify if this is the same MSI issue reported by
>> > Simon.
>> 
>> I tried to test that patch but even without it standby/resume has stopped working:
> 
> Which kernel is this?

linus-2.6 a7f5aaf36ded825477c4d7167cc6eb1bcdc63191

I've reverted to 2b12a4c524812fb3f6ee590a02e65b95c8c32229 where standby/resume still 
works and applied the above patch plus the pci_enable_device patch. It still doesn't 
work after resume if MSI is enabled.

-- 
Simon Arlott
