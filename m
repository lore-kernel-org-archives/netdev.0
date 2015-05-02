From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v2 2/3] ipvlan: Process fragmented multicast
 frames correctly
Date: Fri, 01 May 2015 21:12:25 -0400 (EDT)
Message-ID: <20150501.211225.641281069847184355.davem@davemloft.net>
References: <1430331558-20286-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, dcbw@redhat.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbbEBBM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 21:12:27 -0400
In-Reply-To: <1430331558-20286-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Wed, 29 Apr 2015 11:19:18 -0700

> Multicast processing in IPvlan was faulty as is. Eric Dumazet
> pointed out that fragmented packets won't be processed correctly
> unless defrag step is introduced.
> 
> This patch adds the defrag step before driver attempts to process
> multicast frame(s).
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

And now you are potentially modifying the geometry of packets that
traverse ipvlan devices.

I am sorry but I am going to put my foot down and not allow another
instance of this to happen again.  We already have this being done by
netfilter, and I consider it unacceptable as well as inefficient.

If a fragmented frame is going to be forwarded by us, defragmenting
and refragmenting may create a different outgoing packet stream than
what arrived.  If the outgoing interface's MTU can accomodate the
incoming frames, this kind of modification is absolutely forbidden.
