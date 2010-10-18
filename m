From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 3/5] tipc: Optimizations to bearer enabling logic
Date: Mon, 18 Oct 2010 06:50:17 -0400
Message-ID: <20101018105017.GA16326@hmsreliant.think-freely.org>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
 <1286929558-2954-3-git-send-email-paul.gortmaker@windriver.com>
 <20101013145843.GD31379@hmsreliant.think-freely.org>
 <20101015011139.GB5048@windriver.com>
 <20101015110033.GC22294@hmsreliant.think-freely.org>
 <4CB8C824.7090800@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41708 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507Ab0JRKuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 06:50:39 -0400
Content-Disposition: inline
In-Reply-To: <4CB8C824.7090800@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 05:31:16PM -0400, Paul Gortmaker wrote:
> On 10-10-15 07:00 AM, Neil Horman wrote:
> 
> [...]
> 
> > This definately looks more concise, but I don't see why its necessecary to drop
> > the tipc_net_lock around the call to enable_bearer.  The only caler of
> > tipc_register_media sets the enable_bearer pointer to the enable_bearer
> > function, and  I' don't see any path through that function which would
> > potentially retake that lock.  In fact it seems dropping it might be dangerous,
> > if other paths (like from cfg_named_msg_event), tried to enable a bearer in
> > parallel with a user space directive from the netlink socket).  With out the
> > protection of tipc_net_lock, you could use the same eth_bearer twice, and
> > corrupt that array.
> 
> I think it would be protected by config_lock. but in the end if it is
> just an academic optimization that really isn't in a hot code path
> anyway, and if it just adds more confusion than real world value, then
> I'm fine with just dropping this on the floor (and deleting the extra
> memset in a cleanup patch) -- it won't be the 1st time doing this with
> these carry forward patches, and I'm sure it won't be the last.
> 

Copy that.


> 
