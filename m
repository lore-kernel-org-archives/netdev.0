From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] netlink: fix netlink_ack with large messages
Date: Sat, 9 Nov 2013 00:04:34 +0000
Message-ID: <20131109000434.GD28793@casper.infradead.org>
References: <9333f540a9b87adbdd15e274d12a9d60994fdb34.1383850578.git.jbenc@redhat.com>
 <20131108.150741.966018155704146843.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbenc@redhat.com, netdev@vger.kernel.org, pablo@netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58705 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757639Ab3KIAY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 19:24:59 -0500
Content-Disposition: inline
In-Reply-To: <20131108.150741.966018155704146843.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/13 at 03:07pm, David Miller wrote:
> From: Jiri Benc <jbenc@redhat.com>
> Date: Thu,  7 Nov 2013 19:57:45 +0100
> 
> > Commit c05cdb1b864f ("netlink: allow large data transfers from user-space")
> > does not handle cases where netlink_ack is used to report an error. In such
> > case, the original message is copied to the ack message, which needs to be
> > large enough.
> > 
> > Signed-off-by: Jiri Benc <jbenc@redhat.com>
> 
> I have two problems with this change.
> 
> First of all, if netlink_ack() has this problem, do not extend the
> netlink_alloc_large_skb() usage to dumps too as your patch is
> doing here.
> 
> Secondly, it seems sort of over the top to quote such enormous
> messages, and in fact wasteful.  We have the sequence number in
> the netlink header, so the user can tell exactly which message
> we are erroring.
> 
> Just quoting such huge requests in ACKs by default doesn't seem
> to make any sense.  I would say that we should have a way to
> turn off the quoting, or at least limit it, and turn this knob
> off for things like nftables that can hit these kinds of cases.

I agree it seems over the top for pure ACKs but we also use
netlink_ack() to report errors where it makes sense to quote
the full message.
