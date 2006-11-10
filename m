From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Questions regarding network drivers
Date: Fri, 10 Nov 2006 13:00:06 +0300
Message-ID: <20061110100004.GA18739@2ka.mipt.ru>
References: <771883.63085.qm@web31512.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:31456 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932827AbWKJKAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 05:00:40 -0500
To: Jonathan Day <imipak@yahoo.com>
Content-Disposition: inline
In-Reply-To: <771883.63085.qm@web31512.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 09, 2006 at 07:06:00PM -0800, Jonathan Day (imipak@yahoo.com) wrote:
> Hi,
> 
> I've got an interesting problem to contend with and
> need some advice from the great wise ones here.
> 
> First of all, is it possible (and/or "reasonable
> practice") when developing a network driver to do
> zero-copy transfers between main memory and the
> network device?

What do you mean?
DMA from NIC memory into CPU memory?

> Secondly, the network device is only designed to work
> with short packets and I really want to keep the
> throughput up. My thought was that if I fired off an
> interrupt then transfer a page of data into an area I
> know is safe, the kernel will have enough time to find
> a new safe area and post the address before the next
> page is ready to send.
> 
> Can anyone suggest why this wouldn't work or, assuming
> it can work, why this would be a Bad Idea?

There should not be any kind of 'kernel will have enough time to do
something', instead you must guarantee that there will not be any kind
of races. You can either prealocate several buffers or allocate them on
demand in interrupts.

> Lastly, assuming my sanity lasts that long, would I be
> correct in assuming that the first step in the process
> of getting the driver peer-reviewed and accepted would
> be to post the patches here?

Actually not, the first step in that process is learning jig dance and
of course providing enough beer and other goodies to network maintainers.

> Thanks for any help,

No problem, but to answer at least on of your question more
information should be provided.

> Jonathan Day

-- 
	Evgeniy Polyakov
