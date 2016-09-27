From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] L2TP:Adjust intf MTU,factor underlay L3,overlay
 L2
Date: Tue, 27 Sep 2016 03:31:53 -0400 (EDT)
Message-ID: <20160927.033153.1066118008027608891.davem@davemloft.net>
References: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kleptog@svana.org, jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, nprachan@brocade.com,
        rshearma@brocade.com, dfawcus@brocade.com,
        stephen@networkplumber.org, acme@redhat.com, lboccass@brocade.com
To: parameswaran.r7@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Date: Thu, 22 Sep 2016 13:52:43 -0700 (PDT)

> From ed585bdd6d3d2b3dec58d414f514cd764d89159d Mon Sep 17 00:00:00 2001
> From: "R. Parameswaran" <rparames@brocade.com>
> Date: Thu, 22 Sep 2016 13:19:25 -0700
> Subject: [PATCH] L2TP:Adjust intf MTU,factor underlay L3,overlay L2
> 
> Take into account all of the tunnel encapsulation headers when setting
> up the MTU on the L2TP logical interface device. Otherwise, packets
> created by the applications on top of the L2TP layer are larger
> than they ought to be, relative to the underlay MTU, leading to
> needless fragmentation once the outer IP encap is added.
> 
> Specifically, take into account the (outer, underlay) IP header
> imposed on the encapsulated L2TP packet, and the Layer 2 header
> imposed on the inner IP packet prior to L2TP encapsulation.
> 
> Do not assume an Ethernet (non-jumbo) underlay. Use the PMTU mechanism
> and the dst entry in the L2TP tunnel socket to directly pull up
> the underlay MTU (as the baseline number on top of which the
> encapsulation headers are factored in).  Fall back to Ethernet MTU
> if this fails.
> 
> Signed-off-by: R. Parameswaran <rparames@brocade.com>
> 
> Reviewed-by: "N. Prachanda" <nprachan@brocade.com>,
> Reviewed-by: "R. Shearman" <rshearma@brocade.com>,
> Reviewed-by: "D. Fawcus" <dfawcus@brocade.com>

I have to ask, how do other tunnels over UDP such as VXLAN handle
this problem?
