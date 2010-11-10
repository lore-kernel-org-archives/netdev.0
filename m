From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] Fix CAN info leak/minor heap overflow
Date: Wed, 10 Nov 2010 07:52:27 +0100
Message-ID: <4CDA412B.90900@hartkopp.net>
References: <1288722503.2504.14.camel@dan>	<ygfiq0bsjry.fsf@janus.isnogud.escape.de>	<4CD8FDB5.6060905@hartkopp.net> <20101109.090523.189685701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, security@kernel.org,
	torvalds@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:30609 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424Ab0KJGwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 01:52:47 -0500
In-Reply-To: <20101109.090523.189685701.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.11.2010 18:05, David Miller wrote:
> From: Oliver Hartkopp <socketcan@hartkopp.net>
> Date: Tue, 09 Nov 2010 08:52:21 +0100
> 
>> Once this patch is applied (and the procfs layout is changed anyway), i'd also
>> like to send a patch from my backlog that would extend the procfs output for
>> can-bcm with an additional drop counter.
> 
> I find this kind of discussion extremely disappointing.
> 
> All of this stuff you CAN guys do with procfs files and version
> strings is completely wrong and bogus.
> 
> Once you create a procfs file layout, you're basically stuck and you
> can at best only reasonably add new fields at the end, you can't
> really change existing fields.
> 
> And sysfs would have been a lot more appropriate, you could use
> attributes for each value you want to export and then just add new
> sysfs attributes when you want to export new values which has very
> clear semantics and backwards compatability implications.

I admit that from my todays knowledge i would have done things differently.
But the network layer information bits have been always exposed in /proc/net
as it was in 2003 when we started the implementation on a 2.4.x kernel.
There are netdriver infos in sysfs but no netlayer entries.

>From my point of view the only thing could be to improve the current
situation, which the posted patch does:

- remove kernel addresses that were only relevant at implementation time
- allow AF_CAN protocols to provide their own information due to their needs
- provide inode numbers that can be found in procfs at several places
  => improvements for developers in userspace & kernelspace

The patch has been discussed on SocketCAN ML and the filter entries have not
been identified as a problem for userspace tools. E.g. /proc/net/can/stats is
one of the entries that's used by userspace tools.

IMHO the patch improves the historic situation and fixes the useless leakage
of kernel addresses. Please consider to apply that procfs changes.

Best regards,
Oliver
