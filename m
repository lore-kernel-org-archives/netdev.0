From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Wed, 06 Jul 2016 12:14:20 +1000
Message-ID: <1467771260.13965.97.camel@kernel.crashing.org>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
	 <CAJ3xEMjEup1VUeCr3g2Ry78HvprfnC6wjGd=MWjnMOLWdLyKdQ@mail.gmail.com>
	 <20160705174433.GA73415@ast-mbp.thefacebook.com>
	 <1467754959.13965.66.camel@kernel.crashing.org>
	 <20160706020731.GA82573@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, joel@jms.id.au,
	weixue@trustnetic.com, yuvali@mellanox.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53789 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840AbcGFCOr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 22:14:47 -0400
In-Reply-To: <20160706020731.GA82573@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-07-05 at 19:07 -0700, Alexei Starovoitov wrote:
> 
> Great! Thanks for clarifying.
> So then future netlink api is mandatory to drive this kernel patches?
> How one can use this set without it?

The netlink API is to tweak things, it works reasonably well
autonomously without it.

> What is the main reason for this infra to be in the kernel instead of
> userspace raw socket? Some interaction with the driver, right?
> but it's not obvious from the patches.

There are a few reasons. One it means we can use kernel level
autoconfiguration like DHCP and NFS root which are quite handy when
developing BMC stacks :-)

Another one is that we haven't completely given up on reflecting the
state of the remote NC-SI link into the "carrier status" of the local
interface.

We can't yet do it because the link monitor would stop the driver
queues, but we could possibly invent a flag we set on the device that
prevents this from happening and causes the queues to remain up even
when the link appears down.

This will be useful as some BMCs have multiple NICs that can all do
NC-SI and thus we could have automatic fail over.

Cheers,
Ben.
