From: David Miller <davem@davemloft.net>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Tue, 04 May 2010 00:57:57 -0700 (PDT)
Message-ID: <20100504.005757.97355845.davem@davemloft.net>
References: <AANLkTimf-FWCsiLqYDGg4nl-relRMuNvDowfTKZbe9kx@mail.gmail.com>
	<OF8BB88147.4F3756DA-ON88257719.002A895A-88257719.002AEB08@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: enh@google.com, brian.haley@hp.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51230
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757158Ab0EDH5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 03:57:51 -0400
In-Reply-To: <OF8BB88147.4F3756DA-ON88257719.002A895A-88257719.002AEB08@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: David Stevens <dlstevens@us.ibm.com>
Date: Tue, 4 May 2010 00:48:46 -0700

> It's set to -1 by default, but the common code for unicast and
> multicast in getsockopt is falling through to use the dst_entry.
> 
> I believe (though I haven't actually tried it recently) it actually
> uses "1" for the default value for multicast;

It doesn't, all of the uses in the ipv6 stack say something like:

	if (multicast)
		hlimit = np->mcast_hops;
	else
		hlimit = np->hop_limit;
	if (hlimit < 0)
		hlimit = ip6_dst_hoplimit(dst);

Therefore, the change suggested by Elliot and which I committed is the
way to get the correct behavior and fix this.
