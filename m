From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [E1000-devel] e1000 82546EB MSI support
Date: Mon, 21 Jul 2008 15:07:10 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5205ABB3DA@orsmsx418.amr.corp.intel.com>
References: <4885028E.5050405@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Simon Arlott" <simon@fire.lp0.eu>, <netdev@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37483 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014AbYGUWHR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 18:07:17 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4885028E.5050405@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Arlott wrote:
> MSI support was added to e1000 a long time ago:
> 
> Commit fa4f7ef3aaa6cee6b04ebe90266ee893e0b2ce07 (Wed Nov 1 08:48:10
> 2006 -0800) [e1000: MSI support for PCI-e adapters]
> +       if(adapter->hw.mac_type > e1000_82547_rev_2) {
> +               adapter->have_msi = TRUE;
> +               if((err = pci_enable_msi(adapter->pdev))) {
> +                       DPRINTK(PROBE, ERR,
> +                        "Unable to allocate MSI interrupt Error:
> %d\n", err); +                       adapter->have_msi = FALSE;
> +               }
> +       }
> 
> and commit 9ac98284428961bd5be285a6cc1f5e6f5b6644aa (Thu Apr 28
> 19:39:13 2005 -0700) [e1000: add dynamic generic MSI interrupt
> routine] -       if (adapter->hw.mac_type > e1000_82547_rev_2) {
> +       if (adapter->hw.mac_type >= e1000_82571) {
> 
> Is there are reason why it's only enabled for >= e1000_82571? This
> isn't explained in 
> the commit descriptions or in comments (aside from mentioning that
> the support is for 
> PCI-e cards).
> 
> 82546EB appears to support it (lspci below), but I get multiple TX
> hangs if I enable it: 

That hardware is PCI/PCI-X only and our first design to use MSI-X
interrupt (single vector message based interrupt).  Unfortunately it
didn't work[1].  The solution from the driver side was to make sure that
the driver never enabled it on those parts.  The only parts for gigabit
that correctly support MSI-X are the 82574, 82575 and 82576 based parts.
MSI (single vector) is supported by >= 82571, i.e. 82571/2/3, ESB2,
ICH8/9/10.

Jesse

[1] - http://download.intel.com/design/network/specupdt/82546eb.pdf
see item 26.  The same problem exists on 82546GB as well.
