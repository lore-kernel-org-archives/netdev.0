From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] Fix differences between IPv4 and IPv6
 TCP/UDP checksum calculation
Date: Mon, 14 Mar 2016 01:13:46 -0400 (EDT)
Message-ID: <20160314.011346.677129632153799202.davem@davemloft.net>
References: <20160311215423.13431.64512.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexander.duyck@gmail.com
To: aduyck@mirantis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160311215423.13431.64512.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <aduyck@mirantis.com>
Date: Fri, 11 Mar 2016 14:05:28 -0800

> This patch series is meant to address the differences that exist between
> IPv4 and IPv6 in terms of checksum calculation.  Specifically the IPv6
> function csum_ipv6_magic treated length as a value that could be greater
> than 64K, while csum_tcpudp_magic was truncating the length at 16 bits.
> After looking over the code and giving it some thought I decided it would
> be best to update the IPv4 function so that it worked the same way the IPv6
> one did.  This allows us to get the same results given the same inputs for
> both functions.  As a result we can use the same processes to reverse the
> calculation in the event we need to do something like remove the length of
> the pseudo-header checksum.
> 
> I also took the opportunity to standardize things so that the parameters
> for these functions all use the correct types.  IPv4 addresses are __be32,
> length should always be __u32, and protocol is a __u8.
> 
> With this change in place it corrects an issue with UDP tunnels in which we
> were getting a checksum that was off by 1 when performing fragmentation on
> inner UDP packets.

Series applied, thanks Alexander.
