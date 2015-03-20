From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: introduce IFF_PROTO_DOWN flag.
Date: Fri, 20 Mar 2015 16:28:19 -0400 (EDT)
Message-ID: <20150320.162819.1225364903839854931.davem@davemloft.net>
References: <1426864318-25132-1-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com
To: anuradhak@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbbCTU2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 16:28:21 -0400
In-Reply-To: <1426864318-25132-1-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: anuradhak@cumulusnetworks.com
Date: Fri, 20 Mar 2015 08:11:55 -0700

> Applications can detect errors in the network that would require
> disabling the device independent of the admin state.

I hate changes like this.

The only reason it exists, is because you don't want to put together
the infrastructure and framework necessary for applications managing
this state in userspace to _work_ _together_.  So you make it a kernel
problem.

UP/DOWN is a boolean state, that's not changing.

So you need to design your stuff such that one entity takes all of the
collective decisions together and calculates the final up/down state,
and then asks the kernel to do that.

Nothing is more bullshit than having someone ask the kernel to up the
interface and the thing doesn't come up because of this auxiliary
crap.  That's broken and nobody is going to expect nor be happy with
that behavior.
