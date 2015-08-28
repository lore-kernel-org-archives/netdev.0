From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IGMP: Inhibit reports for local multicast groups
Date: Fri, 28 Aug 2015 13:29:07 -0700 (PDT)
Message-ID: <20150828.132907.1853637831762392208.davem@davemloft.net>
References: <1>
	<6112e6ccb97c5015b6f8125d8c0f75c179b53198.1440689853.git.pdowney@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: pdowney@brocade.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6112e6ccb97c5015b6f8125d8c0f75c179b53198.1440689853.git.pdowney@brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philip Downey <pdowney@brocade.com>
Date: Thu, 27 Aug 2015 16:46:26 +0100

> The range of addresses between 224.0.0.0 and 224.0.0.255 inclusive, is
> reserved for the use of routing protocols and other low-level topology
> discovery or maintenance protocols, such as gateway discovery and
> group membership reporting.  Multicast routers should not forward any
> multicast datagram with destination addresses in this range,
> regardless of its TTL.
> 
> Currently, IGMP reports are generated for this reserved range of
> addresses even though a router will ignore this information since it
> has no purpose.  However, the presence of reserved group addresses in
> an IGMP membership report uses up network bandwidth and can also
> obscure addresses of interest when inspecting membership reports using
> packet inspection or debug messages.
> 
> Although the RFCs for the various version of IGMP (e.g.RFC 3376 for
> v3) do not specify that the reserved addresses be excluded from
> membership reports, it should do no harm in doing so.  In particular
> there should be no adverse effect in any IGMP snooping functionality
> since 224.0.0.x is specifically excluded as per RFC 4541 (IGMP and MLD
> Snooping Switches Considerations) section 2.1.2. Data Forwarding
> Rules:
> 
>     2) Packets with a destination IP (DIP) address in the 224.0.0.X
>        range which are not IGMP must be forwarded on all ports.
> 
> IGMP reports for local multicast groups can now be optionally
> inhibited by means of a system control variable (by setting the value
> to zero) e.g.:
>     echo 0 > /proc/sys/net/ipv4/igmp_link_local_mcast_reports
> 
> To retain backwards compatibility the previous behaviour is retained
> by default on system boot or reverted by setting the value back to
> non-zero e.g.:
>     echo 1 >  /proc/sys/net/ipv4/igmp_link_local_mcast_reports
> 
> Signed-off-by: Philip Downey <pdowney@brocade.com>

Applied to net-next, thanks.
