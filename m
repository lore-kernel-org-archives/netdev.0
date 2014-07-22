From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: Fix for SR-IOV VF initialization
Date: Tue, 22 Jul 2014 15:47:23 -0700
Message-ID: <53CEE9FB.3000405@chelsio.com>
References: <1406026580-27256-1-git-send-email-hariprasad@chelsio.com> <20140722.153440.757089942973087670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com, kumaras@chelsio.com,
	anish@chelsio.com
To: David Miller <davem@davemloft.net>, hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:36346
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933294AbaGVWr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 18:47:28 -0400
In-Reply-To: <20140722.153440.757089942973087670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   Sorry, Hari passed that patch off for review internally but I had 
just gotten back from a backpacking trip at the time.  I'll work with 
him to understand what the issue is.  Unfortunately I'm heading off on a 
second backpacking trip tomorrow so we probably won't be able to resolve 
this till next week.

Casey

On 07/22/14 15:34, David Miller wrote:
> From: Hariprasad Shenai <hariprasad@chelsio.com>
> Date: Tue, 22 Jul 2014 16:26:20 +0530
>
>> Commit 35b1de5 ("rdma/cxgb4: Fixes cxgb4 probe failure in VM when PF is exposed
>> through PCI Passthrough") introduced a regression, where VF failed to
>> initialize. This commit fixes it.
>>
>> Signed-off-by: Casey Leedom <leedom@chelsio.com>
>> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> This commit message need to explain things better, how exactly was
> the regression introduced, what's exactly wrong with the current code?
>
> I actually can't figure it out myself, other than to say that maybe
> replacing things with:
>
> 	func = PCI_FUNC(pdev->devfn);
>   	if (func < ARRAY_SIZE(num_vf) && num_vf[func] > 0)
>   		if (pci_enable_sriov(pdev, num_vf[func]) == 0)
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
