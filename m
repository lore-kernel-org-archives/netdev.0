From: Brian Haley <brian.haley@hp.com>
Subject: Re: IPv6: presentation format for zero scope ID
Date: Mon, 07 Dec 2009 22:27:16 -0500
Message-ID: <4B1DC794.5020406@hp.com>
References: <EA6985CB-3B58-4982-85FE-94C951D2FE5E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>,
	Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:14505 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934778AbZLHD1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 22:27:12 -0500
In-Reply-To: <EA6985CB-3B58-4982-85FE-94C951D2FE5E@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Lever wrote:
> I recently added some functions to sunrpc.ko that behave like
> getnameinfo(AI_NUMERICHOST) does in user space.
> 
> One of the functions, rpc_ntop6(), sticks a scope ID on the end of link-
> and site-local IPv6 addresses.  It does not try to map the scope ID to a
> device name.

Site-local addresses have been deprecated...

> It has been pointed out, however, that glibc's getnameinfo(3) skips
> appending a device name if the scope ID is zero.  Should rpc_ntop6()
> display or ignore zero scope IDs?

A zero scope id implies it's not set, so I would ignore it.  Things like
*bind() and *connect() already do this.

> Would it be better if it also
> converted scope IDs to device names?

*nix typically uses %eth0, Windows uses %1, so I guess if it's for
display purposes I'd do the same thing all the tools use - %name.
This isn't being put in a packet, is it?

> I'm not familiar enough with the IETF mandates regarding presentation
> address format, or the idiosyncrasies of the Linux IPv6 implementation,
> to know what is the desired behavior here.  Any guidance appreciated.

The URI spec (RFC 3986) doesn't cover scope id's, so it winds-up being
implementor's choice.

-Brian
