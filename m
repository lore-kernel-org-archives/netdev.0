From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH RESEND v7] i40e: Look up MAC address in Open Firmware or
 IDPROM
Date: Sat, 5 Dec 2015 15:38:25 -0500
Message-ID: <20151205203825.GA8283@oracle.com>
References: <20151204162407.GM26633@oracle.com>
 <CAP-MU4NdnTH1gj++ZH34NcHvjLjeRFy2=qchORSqP=+G4TjHQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, andy.shevchenko@gmail.com
To: Shannon Nelson <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19703 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbbLEUid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 15:38:33 -0500
Content-Disposition: inline
In-Reply-To: <CAP-MU4NdnTH1gj++ZH34NcHvjLjeRFy2=qchORSqP=+G4TjHQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/04/15 17:40), Shannon Nelson wrote:
> 
> I'd write this just a little differently to match the rest of the driver:
> 
>       ret = i40e_aq_add_macvlan(&vsi->back->hw, vsi->seid, &element, 1, NULL);
>       if (!ret) {

You mean if (ret), right? (i.e., ret == 0 is success)

>               dev_info(&vsi->back->pdev->dev,
>                        "add filter failed err %s aq_err %s\n",

BTW, there are some other places in that file where the return
status form i40e_aq_add_macvlan() is ignored, which makes this a bit
confusing ..
  :
  :

> > +{
> > +       struct device_node *dp = pci_device_to_OF_node(pdev);
> 
> This gives me a compile warning, probably because I don't have
> CONFIG_OF enabled.

Odd, what sort of compile warning? I dont see that on my x86 
machine (and I dont have CONFIG_OF either), and kbuild-test-robot
did not catch that either, afaict. Perhaps you are missing some 
include files?

Without the dp definition, of_get_mac_address() further below
will not find a "dp".

Rest of the comments are addressed in v8 that I just sent out.

--Sowmini
