From: Patrick McHardy <kaber@trash.net>
Subject: Re: Problem with GVRP on eth while having a bridge
Date: Thu, 7 Feb 2013 12:22:27 +0100
Message-ID: <20130207112227.GE13989@macbook.localnet>
References: <51138866.8000802@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexandre DERUMIER <aderumier@odiso.com>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51138866.8000802@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 07, 2013 at 11:56:38AM +0100, Stefan Priebe - Profihost AG wrote:
> Hello list,
> 
> this was tested using vanilla 3.7.6 kernel.
> 
> When i add a vlan to an ethernet device supporting gvrp everything is
> fine until this ethernet device also had a bridge.
> 
> This works fine as long as eth1 is not attached to a bridge.
> 
> # ip link add link eth1 name eth1.99 type vlan id 99 gvrp on
> # ip link set eth1.99 up
> 
> The dynamic VLAN stays up at the switch - no problems.
> 
> If eth1 has a bridge the dynamic vlan is created at the switch so the
> initial packet was send but it disappears after a few seconds.
> 
> Wireshark shows that the kernel has stopped sending GVRP packets. After
> adding a bridge to eth1.

Well, there's no reason why it should continue sending packets after
the switch has been updated unless it receives a message indicating
that the switch is about to remove it from it's tables again. So
please describe the entire GVRP message exchange that's going on.

Also you probably want to add the VLAN device on top of the bridge
device, otherwise it will get passed to the bridge after untagging,
which might not work, depending on the MAC addresses used.
