From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH 05/12] ixgbe: Add SR-IOV features to main module
Date: Wed, 9 Dec 2009 17:53:27 -0800
Message-ID: <43F901BD926A4E43B106BF17856F07558C3DEDC2@orsmsx508.amr.corp.intel.com>
References: <pvmiqcfbpep.fsf@chavey.mtv.corp.google.com>
 <43F901BD926A4E43B106BF17856F07558C3DEDB1@orsmsx508.amr.corp.intel.com>
 <Pine.WNT.4.64.0912091743160.8780@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "chavey@google.com" <chavey@google.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47829 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759205AbZLJBxe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 20:53:34 -0500
In-Reply-To: <Pine.WNT.4.64.0912091743160.8780@ppwaskie-MOBL2.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Waskiewicz Jr, Peter P
>Sent: Wednesday, December 09, 2009 5:44 PM
>To: Rose, Gregory V
>Cc: chavey@google.com; Kirsher, Jeffrey T; netdev@vger.kernel.org;
>gospo@redhat.com; Waskiewicz Jr, Peter P
>Subject: RE: [RFC PATCH 05/12] ixgbe: Add SR-IOV features to main module
>
>On Wed, 9 Dec 2009, Rose, Gregory V wrote:
>
>> >-----Original Message-----
>> >From: chavey@google.com [mailto:chavey@google.com]

[snippage] 

>> >+static inline void ixgbe_disable_sriov(struct ixgbe_adapter
>*adapter)
>> >+{
>> >+       struct ixgbe_hw *hw = &adapter->hw;
>> >+       u32 gcr;
>> >+       u32 gpie;
>> >+       u32 vmdctl;
>> >+
>> >+#ifdef CONFIG_PCI_IOV
>> >+       /* disable iov and allow time for transactions to clear */
>> >+       pci_disable_sriov(adapter->pdev);
>> >+#endif
>> >+       msleep(500);
>> >
>> >what is the sleep used for ?
>> [Rose, Gregory V]
>>
>> It's mostly a safety valve to give plenty of time for all bus
>transactions to complete or time out.
>
>I think Chavey is pointing out that if CONFIG_PCI_IOV is not enabled,
>you'd be sleeping for 500 msecs for no reason.  You should probably
>stick
>the msleep(500) inside the ifdef.
>
>-PJ
[Rose, Gregory V] 

Oh, missed that due to my preconceptions.  My reading of the code is that this function should never be called unless SR-IOV was enabled in the first place (could be wrong of course).  However, for code correctness and readability I agree that the msleep should be moved within the #ifdef.

Added to my community comment notes.

- Greg

