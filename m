From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net: Fix RPF to work with policy routing
Date: Fri, 23 Oct 2009 08:34:49 -0700
Message-ID: <4AE1CD19.8090901@candelatech.com>
References: <1255867954.4815.25.camel@dogo.mojatatu.com>	 <1255868019.4815.27.camel@dogo.mojatatu.com>	 <20091022.214943.105371652.davem@davemloft.net> <1256295075.6264.59.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	atis@mikrotik.com, eric.dumazet@gmail.com, zenczykowski@gmail.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49556 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbZJWPhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 11:37:19 -0400
In-Reply-To: <1256295075.6264.59.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> with the ipt or skbedit actions or via netfilter i could
> set marks which could be as trivial as "set mark X if packet 
> came in via eth0 or eth1 and mark Y if they came in via gre0"
>   
I implemented something similar while allowing for virtual router like
applications.  I had to add a mark very early in the pkt rx logic in dev.c,
and had to add a 'skb_default_mark' member to the netdevice because
the route lookup is done before the normal iptables logic ran.  Without
this, if a flow already existed for pkts coming in eth1, if the packet came
back in eth2, it would use eth1's flow.

I'll dig out the patch if anyone is interested...

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


