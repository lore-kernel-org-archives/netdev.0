From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 3/5] tipc: Optimizations to bearer enabling logic
Date: Fri, 15 Oct 2010 17:31:16 -0400
Message-ID: <4CB8C824.7090800@windriver.com>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com> <1286929558-2954-3-git-send-email-paul.gortmaker@windriver.com> <20101013145843.GD31379@hmsreliant.think-freely.org> <20101015011139.GB5048@windriver.com> <20101015110033.GC22294@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38336 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756363Ab0JOVba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 17:31:30 -0400
In-Reply-To: <20101015110033.GC22294@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-10-15 07:00 AM, Neil Horman wrote:

[...]

> This definately looks more concise, but I don't see why its necessecary to drop
> the tipc_net_lock around the call to enable_bearer.  The only caler of
> tipc_register_media sets the enable_bearer pointer to the enable_bearer
> function, and  I' don't see any path through that function which would
> potentially retake that lock.  In fact it seems dropping it might be dangerous,
> if other paths (like from cfg_named_msg_event), tried to enable a bearer in
> parallel with a user space directive from the netlink socket).  With out the
> protection of tipc_net_lock, you could use the same eth_bearer twice, and
> corrupt that array.

I think it would be protected by config_lock. but in the end if it is
just an academic optimization that really isn't in a hot code path
anyway, and if it just adds more confusion than real world value, then
I'm fine with just dropping this on the floor (and deleting the extra
memset in a cleanup patch) -- it won't be the 1st time doing this with
these carry forward patches, and I'm sure it won't be the last.

Thanks,
Paul.

> 
> Neil
> 


