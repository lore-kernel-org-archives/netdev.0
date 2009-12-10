From: Brian Haley <brian.haley@hp.com>
Subject: Re: IPv6: presentation format for zero scope ID
Date: Thu, 10 Dec 2009 14:32:31 -0500
Message-ID: <4B214CCF.3040207@hp.com>
References: <EA6985CB-3B58-4982-85FE-94C951D2FE5E@oracle.com> <4B1DC794.5020406@hp.com> <20091208080331.3eb5ddfa@tlielax.poochiereds.net> <9E4B7973-D2C4-438C-9BF6-A35B343F2363@oracle.com> <4B2029A1.5010404@hp.com> <3C8ED938-D4F9-4167-BC02-575265B7A56A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Layton <jlayton@redhat.com>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:26795 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688AbZLJTc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 14:32:28 -0500
In-Reply-To: <3C8ED938-D4F9-4167-BC02-575265B7A56A@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Lever wrote:
> One other thing.  This is a rather more broad question, but still
> IPv6-related.
> 
> I'm considering mapping the scope ID to a device name in rpc_ntop6(),
> but it looks like network device names are part of a net namespace, and
> these presentation address strings are shared.  This address string
> might appear in /proc/mounts, for example, but can also be used to send
> messages to user space service daemons like statd or gssd.  We try to do
> the conversion once when certain objects are created (like an RPC client
> data structure) and then save the string.

Devices can be renamed, I'm not sure how common it is after boot though.
If you're not printing it that often the overhead of dev_get_by_index()
probably isn't that high, especially since it now uses RCU.

> Is it OK to leave just the scope ID (for link-local only, of course), or
> might the scope IDs also vary depending on the namespace?  I wouldn't
> think that they would.

Are you asking if a given numeric scope ID could map to a different interface
depending on the namespace?  I don't think so, the ifindex is unique for every
device, but a given network namespace might not contain the device that
matches a certain ifindex.

-Brian
