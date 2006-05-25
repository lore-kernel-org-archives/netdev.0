From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 8/9] Resending NetXen 1G/10G NIC driver patch
Date: Thu, 25 May 2006 09:44:13 -0700
Message-ID: <adaejyijbqa.fsf@cisco.com>
References: <Pine.LNX.4.33.0605250356420.5844-100000@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:31374 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S1030277AbWEYQoP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 12:44:15 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.33.0605250356420.5844-100000@unmsrvr> (Linsys Contractor Amit S. Kale's message of "Thu, 25 May 2006 03:57:31 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +static int __devinit
 > +netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)


 > +#if defined(CONFIG_PCI_MSI)
 > +	adapter->flags |= NETXEN_NIC_MSI_ENABLED;
 > +	if (pci_enable_msi(pdev)) {
 > +		adapter->flags &= ~NETXEN_NIC_MSI_ENABLED;
 > +		printk(KERN_WARNING "%s: unable to allocate MSI interrupt"
 > +		       " error\n", netxen_nic_driver_name);
 > +	}
 > +#endif

No need for the #ifdef -- pci_enable_msi() is stubbed out so it will
always just return failure if CONFIG_PCI_MSI is not set.

 > +	adapterlist[netxen_cards_found++] = adapter;
 > +	adapter->number = netxen_cards_found;

Having a static array of adapters is a bad idea.  Just allocate a
data structure for each card as you probe it.

 - R.
