From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC PATCH 05/12] ixgbe: Add SR-IOV features to main module
Date: Thu, 10 Dec 2009 11:57:40 -0800
Message-ID: <adamy1qlhzf.fsf@roland-alpha.cisco.com>
References: <pvmiqcfbpep.fsf@chavey.mtv.corp.google.com>
	<43F901BD926A4E43B106BF17856F07558C3DEDB1@orsmsx508.amr.corp.intel.com>
	<Pine.WNT.4.64.0912091743160.8780@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rose\, Gregory V" <gregory.v.rose@intel.com>,
	"chavey\@google.com" <chavey@google.com>,
	"Kirsher\, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo\@redhat.com" <gospo@redhat.com>
To: "Waskiewicz Jr\, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:49247 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757137AbZLJT5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 14:57:35 -0500
In-Reply-To: <Pine.WNT.4.64.0912091743160.8780@ppwaskie-MOBL2.amr.corp.intel.com>
	(Waskiewicz Jr's message of "Wed, 9 Dec 2009 17:44:17 -0800 (Pacific
	Standard Time)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > > >+#ifdef CONFIG_PCI_IOV
 > > >+       /* disable iov and allow time for transactions to clear */
 > > >+       pci_disable_sriov(adapter->pdev);
 > > >+#endif
 > > >+       msleep(500);
 > > >
 > > >what is the sleep used for ?
 > > [Rose, Gregory V] 
 > > 
 > > It's mostly a safety valve to give plenty of time for all bus transactions to complete or time out.
 > 
 > I think Chavey is pointing out that if CONFIG_PCI_IOV is not enabled, 
 > you'd be sleeping for 500 msecs for no reason.  You should probably stick 
 > the msleep(500) inside the ifdef.

pci_disable_sriov() calls sriov_disable(), which already does
ssleep(1).  Do you really need another 500 msec of sleep after that 1000
msecs?  My impression of the PCI spec was that the 1 second wait is
supposed to be sufficient.

 - R.
