From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: Re: [PATCH v3] Gigabit Ethernet driver of Topcliff PCH
Date: Wed, 15 Sep 2010 21:26:08 +0900
Message-ID: <001901cb54d3$3c49c010$66f8800a@maildom.okisemi.com>
References: <4C89C23A.6090707@dsn.okisemi.com> <4C89EA12.3000409@suse.cz>  <201009130019.27356.rjw@sisk.pl>
Cc: "David S. Miller" <davem@davemloft.net>,
	"Randy Dunlap" <randy.dunlap@oracle.com>,
	"John Linn" <john.linn@xilinx.com>,
	"Ralf Baechle" <ralf@linux-mips.org>,
	"Kristoffer Glembo" <kristoffer@gaisler.com>,
	"Maxime Bizon" <mbizon@freebox.fr>,
	"Greg Rose" <gregory.v.rose@intel.com>,
	"ML netdev" <netdev@vger.kernel.org>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"MeeGo" <meego-dev@meego.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"FUJITA Tomonori" <fujita.tomonori@lab.ntt.co.jp>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	"Arjan" <arjan@linux.intel.com>,
	"Toshiharu Okada" <okada533@dsn.okisemi.com>,
	"Takahiro Shimizu" <shimizu394@dsn.okisemi.com>,
	"Tomoya Morinaga" <morinaga526@dsn.okisemi.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>, "Jiri Slaby" <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rafael

Thank you for your comment.
I will confirm pci.txt and r8169.c.

Thanks Ohtake.
-----
Date: Mon, 13 Sep 2010 00:19:26 +0200
From: "Rafael J. Wysocki" <rjw@sisk.pl>
> > > > +#ifdef CONFIG_PM
> > > > +static int pch_gbe_resume(struct pci_dev *pdev)
> > > > +{
> > > > + struct net_device *netdev = pci_get_drvdata(pdev);
> > > > + struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> > > > + struct pch_gbe_hw *hw = &adapter->hw;
> > > > + u32 err;
> > > > +
> > > > + pci_enable_wake(pdev, PCI_D0, 0);
> > > > + pci_set_power_state(pdev, PCI_D0);
> > > > + pci_restore_state(pdev);
> > > > + err = pci_enable_device(pdev);
> > > > + if (err) {
> > > > + pr_err("Cannot enable PCI device from suspend\n");
> > > > + return err;
> > > > + }
> > > > + pci_set_master(pdev);
> > >
> > > Not sure which of those you need. Rafael may tell you more. You should
> > > not set power state and restore state, but I might be wrong.
>
> You're basically right.  In fact you're supposed to use struct dev_pm_ops
> for defining PM callbacks and then you don't need do any PCI-specific
> operations directly in the driver.
>
> All of this is described in detail in Documentation/power/pci.txt and you
> can have a look into r8169.c for a reference implementation.
>
> Thanks,
> Rafael
>
