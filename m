From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: don't deliver frames for unknown vlans to
 protocols
Date: Sun, 07 Oct 2012 00:14:10 -0400 (EDT)
Message-ID: <20121007.001410.1223449597402958747.davem@davemloft.net>
References: <20121004165020.GT1162@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jpirko@redhat.com
To: florz@florz.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121004165020.GT1162@florz.florz.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Zumbiehl <florz@florz.de>
Date: Thu, 4 Oct 2012 18:50:20 +0200

> 6a32e4f9dd9219261f8856f817e6655114cfec2f made the vlan code skip marking
> vlan-tagged frames for not locally configured vlans as PACKET_OTHERHOST if
> there was an rx_handler, as the rx_handler could cause the frame to be received
> on a different (virtual) vlan-capable interface where that vlan might be
> configured.
> 
> As rx_handlers do not necessarily return RX_HANDLER_ANOTHER, this could cause
> frames for unknown vlans to be delivered to the protocol stack as if they had
> been received untagged.
> 
> For example, if an ipv6 router advertisement that's tagged for a locally not
> configured vlan is received on an interface with macvlan interfaces attached,
> macvlan's rx_handler returns RX_HANDLER_PASS after delivering the frame to the
> macvlan interfaces, which caused it to be passed to the protocol stack, leading
> to ipv6 addresses for the announced prefix being configured even though those
> are completely unusable on the underlying interface.
> 
> The fix moves marking as PACKET_OTHERHOST after the rx_handler so the
> rx_handler, if there is one, sees the frame unchanged, but afterwards,
> before the frame is delivered to the protocol stack, it gets marked whether
> there is an rx_handler or not.
> 
> Signed-off-by: Florian Zumbiehl <florz@florz.de>

I agree with your analysis but I do not like your fix.

This is one of the hottest paths in the networking stack and I don't
want to add more "pass pointer to local variable" type interfaces.

Fix this in a cleaner way please, thanks
