From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for
 iptables nat routing
Date: Thu, 14 Aug 2008 13:04:25 +0200
Message-ID: <48A41139.9080509@trash.net>
References: <bug-11316-10286@http.bugzilla.kernel.org/>	<20080812221204.46afb4a6.akpm@linux-foundation.org>	<1218679700.23510.8.camel@2710p.home> <20080813.192101.221940876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36143 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752450AbYHNLE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 07:04:28 -0400
In-Reply-To: <20080813.192101.221940876.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Alex Williamson <alex.williamson@hp.com>
> Date: Wed, 13 Aug 2008 20:08:20 -0600
> 
>> git bisect traced the problem back to this changeset:
>>
>>         commit e5a4a72d4f88f4389e9340d383ca67031d1b8536
>>         Author: Lennert Buytenhek <buytenh@marvell.com>
>>         Date:   Sun Aug 3 01:23:10 2008 -0700
>>         
>>             net: use software GSO for SG+CSUM capable netdevices
>>
>> I've verified that I can toggle the slowness by reverting this patch on
>> top of 8d0968ab (current head).  The problem is readily reproducible
>> using Ubuntu Hardy in a KVM VM with upstream, defconfig kernel.
> 
> Patrick I wonder if there a case where iptables NAT will COW the packet
> when it really doesn't need to.

I don't think so, its using skb_make_writable everywhere, which checks
for skb_clone_writable, which should usually avoid COWing local TCP
packets. It would also be unlikely to have that much of a performance
impact (1MB/s -> 34kb/s).

> 
> It seems, if anything, using GSO should make things go a little bit
> faster not slower... Hmmm...

Alex, could you post a tcpdump from both loopback and the outgoing
device from the machine you're doing NAT on?
