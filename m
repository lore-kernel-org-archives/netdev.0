From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] netlink: fix append of whole original message on negative ack.
Date: Fri, 24 Oct 2008 00:55:43 +0400
Message-ID: <20081023205543.GA19462@ioremap.net>
References: <4900BFCF.2030707@gmail.com> <20081023.134513.267548182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michellammertink@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:48276 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818AbYJWUzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Oct 2008 16:55:46 -0400
Content-Disposition: inline
In-Reply-To: <20081023.134513.267548182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Oct 23, 2008 at 01:45:13PM -0700, David Miller (davem@davemloft.net) wrote:
> > Netlink can return an negative acknowledgement, which AFAICT should include an error code and the whole original message. This patch fixes the size argument given to the __nlmsg_put call. Without this patch only the original header was attached.
> > ---
> > 
> > Can anyone explain to me why struct nlmsgerr contains an int error and the nlmsghdr struct. The comment in netlink_ack states that the whole message should be appended. Why not only include an int error in struct nlmsgerr and just append the original message?

Having header (even seq/pid only) is enough to find a message
for that userspace which cares. Looks like your patch can break
existing applications which are used to work with header only,
even if that was a mistake? Although application is supposed to
check the length, it still can expect only a header. I have to
note, that I do not know any such application though.

-- 
	Evgeniy Polyakov
