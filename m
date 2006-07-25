From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Mon, 24 Jul 2006 23:48:53 -0700 (PDT)
Message-ID: <20060724.234853.112197982.davem@davemloft.net>
References: <adasllh9kj0.fsf@cisco.com>
	<20060724.150613.54186472.davem@davemloft.net>
	<20060725055127.GA5103@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, ak@suse.de, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22465
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751466AbWGYGsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 02:48:51 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060725055127.GA5103@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 25 Jul 2006 09:51:28 +0400

> On Mon, Jul 24, 2006 at 03:06:13PM -0700, David Miller (davem@davemloft.net) wrote:
> > Furthermore, the VJ netchannel gains can be partially obtained from
> > generic stateless facilities that we are going to get anyways.
> > Networking chips supporting multiple MSI-X vectors, choosen by hashing
> > the flow ID, can move TCP processing to "end nodes" which are cpu
> > threads in this case, by having each such MSI-X vector target a
> > different cpu thread.
> 
> And if that CPU is very busy?
> Linux should somehow tell NIC that some CPUs are valid and some are not
> right now, but not in a second, so scheduler must be tightly bound with
> network internals.

Yes, it is research problem.

Most of the time, even stateless version will improve things.
>From another viewpoint, even in worst case, it can be no
worse than current situation. :)

BTW, such dynamic remapping is provided for in the NDIS interfaces.
There is an indexing table that is gone through using computed hash to
get "cpu number".
