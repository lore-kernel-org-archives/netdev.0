From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for
 direct ring access
Date: Sun, 05 Oct 2014 21:09:38 -0400 (EDT)
Message-ID: <20141005.210938.412085917241295226.davem@davemloft.net>
References: <20141006000629.32055.2295.stgit@nitbit.x32>
	<20141006002951.GA24376@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, dborkman@redhat.com,
	gerlitz.or@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, john.ronciak@intel.com, amirv@mellanox.com,
	eric.dumazet@gmail.com, danny.zhou@intel.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbaJFBJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 21:09:43 -0400
In-Reply-To: <20141006002951.GA24376@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 6 Oct 2014 02:29:51 +0200

> John Fastabend <john.fastabend@gmail.com> wrote:
>> There is one critical difference when running with these interfaces
>> vs running without them. In the normal case the af_packet module
>> uses a standard descriptor format exported by the af_packet user
>> space headers. In this model because we are working directly with
>> driver queues the descriptor format maps to the descriptor format
>> used by the device. User space applications can learn device
>> information from the socket option PACKET_DEV_DESC_INFO which
>> should provide enough details to extrapulate the descriptor formats.
>> Although this adds some complexity to user space it removes the
>> requirement to copy descriptor fields around.
> 
> I find it very disappointing that we seem to have to expose such
> hardware specific details to userspace via hw-independent interface.
> 
> How big of a cost are we talking about when you say that it 'removes
> the requirement to copy descriptor fields'?

FWIW, it also avoids the domain switch (which is just a fancy way
to refer to performing the system call), both in and out.
