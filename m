From: James Chapman <jchapman@katalix.com>
Subject: Re: [RFC PATCH] ppp: add support for L2 multihop / tunnel switching
Date: Mon, 09 Jul 2012 12:52:15 +0100
Message-ID: <4FFAC5EF.6030003@katalix.com>
References: <20120708214930.GI19462@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20120708214930.GI19462@kvack.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/07/12 22:49, Benjamin LaHaise wrote:
> Hello folks,
> 
> Below is a first cut at implementing multihop L2TP, also known as tunnel 
> switching.  The feature is similar in scope to how PPPoE relaying works -- 
> L2 packets that are received on one PPP interface are forwarded to another.  
> This feature is typically used for traffic aggregation and backhaul for 
> ISPs, with incoming sessions (often PPPoE) being partially authenticated 
> by a LAC, and then forwarded over an L2TP session to an LNS (selected by the 
> user's domain) which then provides network access to the client.

As a mechanism for switching PPP interfaces together, this patch is
good. For L2TP though, I prefer an approach that would be applicable for
all L2TP traffic types, not just PPP.

L2TP supports many different pseudowire types, and this patch will only
be useful for tunnel switching between PPP pseudowires. Whereas if we
implement it within the L2TP core, rather than in the PPP code, we would
get switching between all pseudowire types. If we add this patch and
then subsequently add switching between other pseudowires in the L2TP
core (which we're likely to want to do), then we're left with two
different interfaces for doing L2TP tunnel switching in the kernel.

The L2TP core allows traffic to be passed directly into an L2TP session.
In the case of PPPoE, for example, the PPP data can be  extracted from a
PPPoE packet and passed into an L2TP tunnel/session, with no PPP
interface(s) involved.

That said, your approach allows two PPP interfaces to be switched
together, which has its own advantages.

> The reasoning behind using dev_queue_xmit() rather than outputting directly 
> to another PPP channel is to enable the use of the traffic shaping and 
> queuing features of the kernel on multihop sessions.

I'm not sure about using a pseudo packet type to do this. For L2TP, it
would seem better to add netfilter/tc support for L2TP data packets,
which would let people add rules for, say, traffic in L2TP tunnel x /
session y. This would avoid the need for ETH_P_PPP and you could then
output directly to the ppp channel.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development


