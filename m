From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bridge] [PATCH] bridge hub_enabled option
Date: Tue, 29 Mar 2005 14:27:19 -0800
Message-ID: <20050329142719.4bd7cb57@dxpl.pdx.osdl.net>
References: <20050326224030.GA31822@darkalpt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@lists.osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Alpt <alpt@freaknet.org>
In-Reply-To: <20050326224030.GA31822@darkalpt>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Mar 2005 23:40:30 +0100
Alpt <alpt@freaknet.org> wrote:

> 
> Bridge hub_enabled patch:
> this patch adds the hub_enabled option for bridge.
> 
> By default the hub_enabled flag is set to 1. In this case nothing changes, the
> bridge, as usually, acts as a hub and flood_forward the input pkts to all its
> ports. When hun_enabled is set to 0, the bridge stops to flood_forward the input
> traffic and takes only the pkts sent to it.
> Disabling the hub option is useful to join multiple interfaces into a unique virtual
> one, thus becomes possible to have easily an ad-hoc network topology using multiple
> interfaces.

Could you give a better example of how this would be useful?
Why would you not want A to talk to C? 
Why not enforce the policy with ebtables?


> 
> For example:
> 
> 
> 	A(eth0) --- (eth1)B(eth0) --- (eth1)C
> 		       BRIDGE
> 		       NO HUB
> 		        br0
> A and C must not be directly connected, and B must have only one interface, in
> this case br0.
> This scenario is possible only disabling the hub behavior of the bridge.
> 
> To clarify, this topology is the same of having:
> 
> 	A(wlan0)\	     /(wlan0)C
> 		 \	    /
> 		  \	   /
> 		    (wlan0)
> 		      B
> A and C don't see each other.
> 
> 
> Maybe the hub_enabled option may be useful for something else ^_-
> 
> The patch is simple and stupid, and it seems to work.
> 

Also, since you broken the connectivity, anybody who is using multiple bridges
and spanning tree is going to create dead zones.
