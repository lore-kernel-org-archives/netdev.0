From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 17:20:47 -0400 (EDT)
Message-ID: <20110523.172047.1438754754048434316.davem@davemloft.net>
References: <4DDAB72B.9050101@gmail.com>
	<4DDAC26C.2070601@candelatech.com>
	<20110523140048.777fb378@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, nicolas.2p.debian@gmail.com,
	ebiederm@xmission.com, jpirko@redhat.com, xiaosuo@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030356Ab1EWVWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 17:22:51 -0400
In-Reply-To: <20110523140048.777fb378@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 23 May 2011 14:00:48 -0700

> IMHO the REORDER_HDR flag was a design mistake. It means supporting
> two different API's for the application. For a packet capture application
> it means the format of the packet will be different based on how
> the VLAN was created. And the vlan was created outside the application.
> 
> If there was a requirement to support both formats, then it should
> be a property of the AF_PACKET socket.  The application can then do
> an setsockopt() to control the format of the data. The issue is
> for things like mmap/AF_PACKET the re-inserted form will be slower
> since data has to be copied.

Indeed, it was a foolish thing to support in the first place.

I guess we couldn't see the hw offloads in the future at that
point.

I'm all for finding a way to deprecate this over time.
