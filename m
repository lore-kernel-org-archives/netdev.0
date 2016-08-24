From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH] net: ip_finish_output_gso: Attempt gso_size clamping
 if segments exceed mtu
Date: Wed, 24 Aug 2016 16:59:42 +0200
Message-ID: <20160824145942.GB7905@breakpoint.cc>
References: <1471867570-1406-1-git-send-email-shmulik.ladkani@gmail.com>
 <20160822125842.GF6199@breakpoint.cc>
 <20160824175350.34df9f3b@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46496 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753216AbcHXPUx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 11:20:53 -0400
Content-Disposition: inline
In-Reply-To: <20160824175350.34df9f3b@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:
> > Normal ipv4 routing via vm1, no iptables etc. present, so
> > 
> > we have  hypervisor 1500 -> 1500 VM1 1280 -> 1280 VM2
> > 
> > Turning off gro avoids this problem.
> 
> I hit the BUG only when VM2's mtu is not set to 1280 (kept to the 1500
> default).

Right, 

> Otherwise, Hypervisor's TCP stack (sender) uses TCP MSS advertised by
> VM2 (which is 1240 if VM2 mtu properly configured), thus GRO taking
> place in VM1's eth0 is based on arriving segments (sized 1240).

True.

> Only if VM2 has mtu of 1500, the MSS seen by Hypervisor during handshake
> is 1460, thus GRO acting on VM1's eth0 is based on 1460 byte segments.
> This leads to "gso clamping" taking place, with the BUG in skb_segment
> (which btw, seems sensitive to change in gso_size only if GRO was
> merging into frag_list).
> 
> Can you please acknowledge our setup and reproduction are aligned?

Yes, seems setups are identical.
