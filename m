From: Moni Shoua <monis@voltaire.com>
Subject: Re: [PATCH] IB/ipoib: Bound the net device to the ipoib_neigh structue
Date: Wed, 10 Oct 2007 18:03:45 +0200
Message-ID: <470CF7E1.6060503@voltaire.com>
References: <11916151232222-git-send-email-fubar@us.ibm.com> <470C200D.4010705@pobox.com> <470C2343.1020800@garzik.org> <20071009.181246.41634534.davem@davemloft.net> <706.1191979132@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ogerlitz@voltaire.com,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:41110 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756692AbXJJQEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 12:04:11 -0400
In-Reply-To: <706.1191979132@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Jeff Garzik <jeff@garzik.org>
>> Date: Tue, 09 Oct 2007 20:56:35 -0400
>>
>>> Jeff Garzik wrote:
>>>> applied patches 1-9
>>>>
>>>> the only thing that was a hiccup during submission is that your email 
>>>> subject lines did not contain a notion of ordering "[PATCH 1/9] ...". 
>>>> But other than that, the git-send-email went flawlessly.
>>> unfortunately it does not seem to build flawlessly:
>> Yeah it doesn't handle Stephen Hemmingers headerops change
>> in net-2.6.24
> 
> 	Gaah.  I'll sort it out and repost.
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

Hi Jay, Jeff
Thanks for the help with making the patch work compile under 2.6.24.
However, patch #3 has a missing line in bond_setup_by_slave that should look like this

	bond_dev->header_ops        = slave_dev->header_ops;

I rewrote the patch and also fixed patch #8 that became broken.

I would send the new patches now but there is more....
I also ran a test for the code in the branch of 2.6.24 and found a problem.
I see that ifconfig down doesn't return (for IPoIB interfaces) and it's stuck in napi_disable() in the kernel (any idea why?)

I am trying to solve it now so I'd like to wait a short time before applying these patches. 
I guess that I'll need to add something.



thanks
   MoniS

