From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH 05/12] ixgbe: Add SR-IOV features to main module
Date: Thu, 10 Dec 2009 12:02:38 -0800
Message-ID: <43F901BD926A4E43B106BF17856F07558C3DF1D9@orsmsx508.amr.corp.intel.com>
References: <pvmiqcfbpep.fsf@chavey.mtv.corp.google.com>
	<43F901BD926A4E43B106BF17856F07558C3DEDB1@orsmsx508.amr.corp.intel.com>
	<Pine.WNT.4.64.0912091743160.8780@ppwaskie-MOBL2.amr.corp.intel.com>
 <adamy1qlhzf.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "chavey@google.com" <chavey@google.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Roland Dreier <rdreier@cisco.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20908 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757AbZLJUCi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 15:02:38 -0500
In-Reply-To: <adamy1qlhzf.fsf@roland-alpha.cisco.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Roland Dreier [mailto:rdreier@cisco.com]
>Sent: Thursday, December 10, 2009 11:58 AM
>To: Waskiewicz Jr, Peter P
>Cc: Rose, Gregory V; chavey@google.com; Kirsher, Jeffrey T;
>netdev@vger.kernel.org; gospo@redhat.com
>Subject: Re: [RFC PATCH 05/12] ixgbe: Add SR-IOV features to main module
>
>
> > > >+#ifdef CONFIG_PCI_IOV
> > > >+       /* disable iov and allow time for transactions to clear */
> > > >+       pci_disable_sriov(adapter->pdev);
> > > >+#endif
> > > >+       msleep(500);
> > > >
> > > >what is the sleep used for ?
> > > [Rose, Gregory V]
> > >
> > > It's mostly a safety valve to give plenty of time for all bus
>transactions to complete or time out.
> >
> > I think Chavey is pointing out that if CONFIG_PCI_IOV is not enabled,
> > you'd be sleeping for 500 msecs for no reason.  You should probably
>stick
> > the msleep(500) inside the ifdef.
>
>pci_disable_sriov() calls sriov_disable(), which already does
>ssleep(1).  Do you really need another 500 msec of sleep after that 1000
>msecs?  My impression of the PCI spec was that the 1 second wait is
>supposed to be sufficient.
[Rose, Gregory V] 

I think you're correct.  I'll just pull the msleep(500) and do some local functional testing to make sure it doesn't cause any problems.  If not then I'll remove it permanently.

- Greg

