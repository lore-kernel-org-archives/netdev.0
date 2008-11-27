From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter 11/29: nf_nat: remove warn_if_extra_mangle
Date: Thu, 27 Nov 2008 19:28:37 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0811271927060.21626@fbirervta.pbzchgretzou.qr>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet> <20081127161518.13891.2929.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161518.13891.2929.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2008-11-27 17:15, Patrick McHardy wrote:

>    netfilter: nf_nat: remove warn_if_extra_mangle
>    
>    In net/ipv4/netfilter/nf_nat_rule.c, the function warn_if_extra_mangle was added
>    in commit 5b1158e909ecbe1a052203e0d8df15633f829930 (2006-12-02). I have a DNAT
>    target in the OUTPUT chain than changes connections with dst 2.0.0.1 to another
>    address which I'll substitute with 66.102.9.99 below.
>    
>    On every boot I get the following message:
>    [  146.252505] NAT: no longer support implicit source local NAT
>    [  146.252517] NAT: packet src 66.102.9.99 -> dst 2.0.0.1
>    
>    As far as I can tell from reading the function doing this, it should warn if the
>    source IP for the route to 66.102.9.99 is different from 2.0.0.1 but that is not
>    the case. It doesn't make sense to check the DNAT target against the local route
>    source.
>    
>    Either the function should be changed to correctly check the route, or it should
>    be removed entirely as it's been nearly 2 years since it was added.

Why did implicit local SNAT even go? It was kind of a neat way to
be able to issue `socat - tcp-client:localhost:1234` and have
it redirected elsewhere on the net.
