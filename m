From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 ipv6_select_ident
Date: Thu, 22 Dec 2011 11:01:25 +0100
Message-ID: <20111222100125.GS6348@secunet.com>
References: <4EF23BF2.4000601@bootc.net>
 <1324499332.2621.7.camel@edumazet-laptop>
 <1324500775.2621.9.camel@edumazet-laptop>
 <4EF2568C.6040006@bootc.net>
 <AEC29013-98F3-4A16-A88B-AD31C9E88EB8@bootc.net>
 <1324528656.2621.19.camel@edumazet-laptop>
 <20111222063806.GP6348@secunet.com>
 <1324540277.2621.41.camel@edumazet-laptop>
 <20111222075830.GR6348@secunet.com>
 <1324541138.2621.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Boot <bootc@bootc.net>, lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1324541138.2621.45.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2011 at 09:05:38AM +0100, Eric Dumazet wrote:
> 
> By the way we no longer have this 1500 hard coded, not sure it it
> matters or not, but it looks better anyway.
> 

It looks like the bridge code sets the mtu value on this metric
to the mtu of the bridge device in br_add_if(). So seems to be
not really fixed to 1500. Not sure why netfilter really needs
to have this 1500 in the metric before the mtu is initialized
from the bridge code.  

We could make fake_mtu() look like dn_dst_mtu(). The mtu of the
bridge device should be reflected in the metric once the bridge
code initialized it. Also learned pmtu values would be taken
into account then.
