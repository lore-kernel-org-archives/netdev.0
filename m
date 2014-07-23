From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] cxgb4: Fix for SR-IOV VF initialization
Date: Tue, 22 Jul 2014 20:01:04 -0700
Message-ID: <53CF2570.50103@gmail.com>
References: <1406026580-27256-1-git-send-email-hariprasad@chelsio.com> <20140722.153440.757089942973087670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com
To: David Miller <davem@davemloft.net>, hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:55612 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755689AbaGWDBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 23:01:07 -0400
Received: by mail-pd0-f176.google.com with SMTP id y10so719611pdj.7
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 20:01:06 -0700 (PDT)
In-Reply-To: <20140722.153440.757089942973087670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 03:34 PM, David Miller wrote:
> From: Hariprasad Shenai <hariprasad@chelsio.com>
> Date: Tue, 22 Jul 2014 16:26:20 +0530
> 
>> Commit 35b1de5 ("rdma/cxgb4: Fixes cxgb4 probe failure in VM when PF is exposed
>> through PCI Passthrough") introduced a regression, where VF failed to
>> initialize. This commit fixes it.
>>
>> Signed-off-by: Casey Leedom <leedom@chelsio.com>
>> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> 
> This commit message need to explain things better, how exactly was
> the regression introduced, what's exactly wrong with the current code?
> 
> I actually can't figure it out myself, other than to say that maybe
> replacing things with:
> 
> 	func = PCI_FUNC(pdev->devfn);
>  	if (func < ARRAY_SIZE(num_vf) && num_vf[func] > 0)
>  		if (pci_enable_sriov(pdev, num_vf[func]) == 0)
> 
> would work equally as well.  That's precisely what the code was
> doing before the mentioned commit.
> 
> Why do we have to iterate over _ALL_ functions of the PCI device,
> rather than just directly enable SRIOV on the one function whether
> it bet PCI_FUNC(pdev->devfn) or that WHOAMI value?
> 
> You need to explain this so that people understand the how and the
> why of your changes.
> 
> Thanks.

What it looks like it is doing is forcing the loop to iterate over
multiple PFs enabling SR-IOV on each one.  Same thing for disabling on
remove.  I would think this would fail for a multifunction device since
calling this a pci_enable_sriov a second time with values when SR-IOV is
enabled should return -EINVAL.

I thought the use of module parameters for SR-IOV had been deprecated in
favor of the PCI sysfs approach?  It seems like switching over might be
a better way to resolve whatever issue this was trying to address.

Thanks,

Alex
