From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: NAPI: netif_rx_reschedule() ??
Date: Wed, 30 Aug 2006 16:38:29 -0700
Message-ID: <20060830163829.5843c3c7@localhost.localdomain>
References: <adau03tlvx8.fsf@cisco.com>
	<20060830161219.7878bada@localhost.localdomain>
	<adapsehls1r.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64673 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751173AbWH3Xia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 19:38:30 -0400
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adapsehls1r.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2006 16:31:12 -0700
Roland Dreier <rdreier@cisco.com> wrote:

>     Stephen> The undo should really be handled by the caller, not in
>     Stephen> netif_rx_reschedule.  The existing interface assumes you
>     Stephen> have already deducted N from your quota and so it needs
>     Stephen> to be put back.
> 
> makes sense -- especially since the caller probably also deducted N
> from *budget, and netif_rx_reschedule() doesn't touch that.

Changing it wouldn't be hard with only a couple of users.

> 
>     Stephen> If poll is already scheduled, then after leaving this
>     Stephen> poll call, another will occur.  If the poll routine just
>     Stephen> went ahead and rescanned that would work as well. The
>     Stephen> important part is not to leave the poll routine without
>     Stephen> being in one of these states: * all work is done, and
>     Stephen> hardware is empty and/or will interrupt for more.  * some
>     Stephen> work was done, and device left on poll_list with softirq
>     Stephen> raised
> 
> But how does the return value of netif_rx_reschedule() help anything?
> It either tells you that a poll was already scheduled, or that it
> succeeded in scheduling a poll.  In either case another poll will
> happen.  So why should the caller care?
> 
> Or is it possible that netif_rx_reschedule() returning 0 might mean
> that it failed to reschedule the poll routine?  But even if that's
> true, how can the caller use that -- 0 might mean the poll was already
> rescheduled, and it might mean that the poll couldn't be resheduled,
> but there's no way for the caller to know which.
> 
>  - R.

The return value doesn't really help. It should just be a void
function, the resulting state is the same in either case.

-- 
Stephen Hemminger <shemminger@osdl.org>
