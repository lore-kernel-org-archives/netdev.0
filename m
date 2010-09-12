From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v3] Gigabit Ethernet driver of Topcliff PCH
Date: Mon, 13 Sep 2010 00:19:26 +0200
Message-ID: <201009130019.27356.rjw@sisk.pl>
References: <4C89C23A.6090707@dsn.okisemi.com> <4C89EA12.3000409@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	John Linn <john.linn@xilinx.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Greg Rose <gregory.v.rose@intel.com>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, MeeGo <meego-dev@meego.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Arjan <arjan@linux.intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:47740 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753892Ab0ILWUi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Sep 2010 18:20:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, September 10, 2010, Rafael J. Wysocki wrote:
> On Friday, September 10, 2010, Jiri Slaby wrote:
> > Ccing Rafael (please find pch_gbe_resume here)

Thanks.

...
> > 
> > > +#ifdef CONFIG_PM
> > > +static int pch_gbe_resume(struct pci_dev *pdev)
> > > +{
> > > +	struct net_device *netdev = pci_get_drvdata(pdev);
> > > +	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> > > +	struct pch_gbe_hw *hw = &adapter->hw;
> > > +	u32 err;
> > > +
> > > +	pci_enable_wake(pdev, PCI_D0, 0);
> > > +	pci_set_power_state(pdev, PCI_D0);
> > > +	pci_restore_state(pdev);
> > > +	err = pci_enable_device(pdev);
> > > +	if (err) {
> > > +		pr_err("Cannot enable PCI device from suspend\n");
> > > +		return err;
> > > +	}
> > > +	pci_set_master(pdev);
> > 
> > Not sure which of those you need. Rafael may tell you more. You should
> > not set power state and restore state, but I might be wrong.

You're basically right.  In fact you're supposed to use struct dev_pm_ops
for defining PM callbacks and then you don't need do any PCI-specific
operations directly in the driver.

All of this is described in detail in Documentation/power/pci.txt and you
can have a look into r8169.c for a reference implementation.

Thanks,
Rafael
