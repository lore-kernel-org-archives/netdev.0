From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [net-next PATCH 2/3] net/qdisc: IFF_NO_QUEUE drivers should use
 consistent TX queue len
Date: Thu, 3 Nov 2016 13:54:40 -0700
Message-ID: <20161103205440.GB2940@templeofstupid.com>
References: <20161103135534.28737.37657.stgit@firesoul>
 <20161103135606.28737.67383.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>,
        Robert Olsson <robert@herjulf.se>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:54535 "EHLO
        homiemail-a40.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757963AbcKCUym (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:54:42 -0400
Received: from homiemail-a40.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a40.g.dreamhost.com (Postfix) with ESMTP id 049946005801
        for <netdev@vger.kernel.org>; Thu,  3 Nov 2016 13:54:42 -0700 (PDT)
Received: from kmjvbox (c-73-202-117-160.hsd1.ca.comcast.net [73.202.117.160])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a40.g.dreamhost.com (Postfix) with ESMTPSA id DCB7C6005737
        for <netdev@vger.kernel.org>; Thu,  3 Nov 2016 13:54:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161103135606.28737.67383.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 03, 2016 at 02:56:06PM +0100, Jesper Dangaard Brouer wrote:
> The flag IFF_NO_QUEUE marks virtual device drivers that doesn't need a
> default qdisc attached, given they will be backed by physical device,
> that already have a qdisc attached for pushback.
> 
> It is still supported to attach a qdisc to a IFF_NO_QUEUE device, as
> this can be useful for difference policy reasons (e.g. bandwidth
> limiting containers).  For this to work, the tx_queue_len need to have
> a sane value, because some qdiscs inherit/copy the tx_queue_len
> (namely, pfifo, bfifo, gred, htb, plug and sfb).
> 
> Commit a813104d9233 ("IFF_NO_QUEUE: Fix for drivers not calling
> ether_setup()") caught situations where some drivers didn't initialize
> tx_queue_len.  The problem with the commit was choosing 1 as the
> fallback value.
> 
> A qdisc queue length of 1 causes more harm than good, because it
> creates hard to debug situations for userspace. It gives userspace a
> false sense of a working config after attaching a qdisc.  As low
> volume traffic (that doesn't activate the qdisc policy) works,
> like ping, while traffic that e.g. needs shaping cannot reach the
> configured policy levels, given the queue length is too small.

Thanks for fixing this.  I've run into this in the exact scenario you
describe -- bandwith limiting containers.  I'm pretty sure my vote
doesn't count, but I'm in favor of this change.

-K
