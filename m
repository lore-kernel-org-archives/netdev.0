From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [net-next PATCH v3] ipv4: allow warming up the ARP cache with
 request type gratuitous ARP
Date: Tue, 19 Jan 2010 21:18:18 +1030
Message-ID: <20100119211818.28f48713@opy.nosense.org>
References: <201001190058.44495.opurdila@ixiacom.com>
	<20100119100913.65177497@opy.nosense.org>
	<20100119.021138.172154379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, ja@ssi.bg, chavey@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:53700 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356Ab0ASKse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 05:48:34 -0500
In-Reply-To: <20100119.021138.172154379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Tue, 19 Jan 2010 02:11:38 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
> Date: Tue, 19 Jan 2010 10:09:13 +1030
> 
> > I don't think this complies with the ARP RFC (RFC826). Walking through
> > the validation steps, Gratuitous ARP seems to only pass if there is an
> > existing entry in the table, otherwise they'd fail, as the target
> > address in the GA packet doesn't match that of the receiving host.
> 
> It's fine if it's guarded by the per-device ARP_ACCEPT sysctl which
> defaults to off, and that's what he's doing.

Fair enough.

I wasn't familiar with the ARP_ACCEPT sysctl. It seems that this patch
is not only adding the feature of creating new ARP table entries in
response to GARPs, but is also fixing the ARP implementation because it
looks like the default wasn't to accept GARPs, despite the validation
steps in RFC826 allowing them. 

ARP_ACCEPT / the /proc "arp_accept" file is really confusingly named -
unless you knew better I doubt anybody would guess it's only referring
to GARPs. Is there any chance of renaming it or symlinking a new name
of something like "garp_accept" to the old one? Is this a significant
enough behaviour change that it creates that opportunity?

Regards,
Mark.
