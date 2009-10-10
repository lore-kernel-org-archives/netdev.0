From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: Very strange issues with ethernet wake on lan
Date: Sat, 10 Oct 2009 23:37:19 +0200
Message-ID: <1255210639.4199.0.camel@maxim-laptop>
References: <1250394174.32268.13.camel@localhost.localdomain>
	<200909292228.18200.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pm@lists.linux-foundation.org" <linux-pm@lists.linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <200909292228.18200.rjw@sisk.pl>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-09-29 at 22:28 +0200, Rafael J. Wysocki wrote: 
> On Sunday 16 August 2009, Maxim Levitsky wrote:
> > Hi,
> > 
> > I have recently put back the davicom dm9009 ethernet card into my
> > computer.
> > 
> > Some long time ago, I have written its suspend/resume routines.
> > Now I see that few things have changed, like I need to enable wake in
> > sysfs or better patch the code to do so, some nice helpers like
> > pci_prepare_to_sleep have arrived, etc.
> > 
> > 
> > I narrowed the strange issue down to following situation:
> > 
> > I reload dmfe.ko (and networkmanager is disabled)
> > I don't ifup the device, thus pretty much no hardware initialization
> > takes place (but this appears not to matter anyway)
> > 
> > I then suspend the system, and WOL doesn't work (I have patched the
> > driver to enable WOL automaticly)
> > 
> > I then, suspend again. WOL works, and continues to work as long as I
> > don't reload the driver. If I do, same situation repeats.
> > 
> > Also, after a boot, WOL works, so a reload cycle triggers that issue.
> > 
> > And most importantly, if I don't do a
> > 
> > pci_set_power_state(pci_dev, pci_choose_state (pci_dev, state));
> > 
> > in .suspend, then WOL always works.
> > 
> > and I have even tried to set state manually to PCI_D3hot or PCI_D3cold, 
> > 
> > I also tried to use pci_save_state
> > 
> > 
> > I also have 2 copies of this card, and both have this issue.
> > I also tried 2 pci slots.
> > 
> > Kernel is vanilla 2.6.31-rc5
> 
> Please check if this still happens with 2.6.32-rc1.

It doesn't! (-git as of today tested)

Thanks,
Best regards,
Maxim Levitsky

> 
> Best,
> Rafael
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
