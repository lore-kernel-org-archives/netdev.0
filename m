From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 10/11][INET] Eliminate difference in actions
 of sysctl and proc handler for conf.all.forwarding
Date: Wed, 05 Dec 2007 01:48:35 -0800 (PST)
Message-ID: <20071205.014835.45293431.davem@davemloft.net>
References: <4755256F.9000505@openvz.org>
	<4755290D.2090709@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58615
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750979AbXLEJsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:48:36 -0500
In-Reply-To: <4755290D.2090709@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 04 Dec 2007 13:16:45 +0300

> AFAIS the net.ipv4.conf. <dev>, all and default sysctls should 
> work like this when changed (besides changing the value itself):
> 
> <dev>   : optionally do smth else
> all     : walk devices
> default : walk devices
> 
> The proc handler for net.ipv4.conf.all works like this:
> 
> <dev>   : flush rt cache
> all     : walk devices and flush rt cache
> default : nothing
> 
> while the sysctl handler works like this:
> 
> <dev>   : nothing
> all     : nothing
> default : walk devices but don't flush the cache
> 
> All this looks strange. Am I right that regardless of whatever
> handler (proc or syscall) is called the behavior should be:
> 
> <dev>   : flush rt cache
> all     : walk the devices and flush the cache
> default : walk the devices and flush the cache
> 
> ?
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Because, basically, nobody (and I really do mean nobody)
uses the sysctl() method to change these things, what
people expect is basically going to be the procfs
access behavior.

And I agree with it.

The 'default' influences future settings, it should not modify
existing devices.  That's the job of 'all'.

Otherwise why have 'all' and 'default' as two different knobs
if they do exactly the same thing?  That's pointless.

I've therefore dropped this patch.
