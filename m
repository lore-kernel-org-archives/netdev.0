From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: VLAN rx acceleration bypasses bridge
Date: Sat, 24 Oct 2009 11:11:52 -0700
Message-ID: <20091024111152.6299a203@nehalam>
References: <1255564685.21615.131.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49150 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751790AbZJXSMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 14:12:05 -0400
In-Reply-To: <1255564685.21615.131.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Oct 2009 01:58:05 +0200
Maxime Bizon <mbizon@freebox.fr> wrote:

> 
> Hi Patrick, Stephen & all,
> 
> 
> If I do:
> 
> # vconfig add eth0 100
> # brctl addbr br0
> # brctl addif br0 eth0
> 
> Then eth0.100 gets no more packet and br0.100 should be used instead to
> get tagged packets.
> 
> But, if vlan rx acceleration is enabled on eth0, then vlan 100 packets
> no longer go through bridge, and eth0.100 is to be used instead.
> 
> This is fixable, but I'm not sure which behavior is preferred ?
> 
> 
> In case we prefer the first one, how could someone bridge untagged
> packets from eth0 with some tagged packets from eth1, and some tagged
> packets from eth0 with untagged packets from eth1 ?
> 
> Something like this, which currently works when vlan rx accel is on:
> 
> # vconfig add eth0 100
> # vconfig add eth1 100
> # brctl addbr br0
> # brctl addif br0 eth0
> # brctl addif br0 eth1.100
> # brctl addbr br1
> # brctl addif br1 eth0.100
> # brctl addif br1 eth1
> 
> 
> Regards,
> 

The way I see it, if you define a vlan then you need to bridge that
vlan. Mixing plain and vlanned interfaces is a mess that is hard to untangle
and probably not worth fixing.
