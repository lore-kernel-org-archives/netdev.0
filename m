From: Lincoln Dale <ltd@cisco.com>
Subject: Re: [PATCH] [RFC] Support for wccp version 1 and 2 in ip_gre.c
Date: Tue, 14 Sep 2004 23:07:50 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20040914225341.03c31a08@171.71.163.14>
References: <5.1.0.14.2.20040914184652.03e24de0@171.71.163.14>
 <20040913051706.GB26337@stingr.sgu.ru>
 <20040911194108.GS28258@stingr.sgu.ru>
 <20040912170505.62916147.davem@davemloft.net>
 <20040913051706.GB26337@stingr.sgu.ru>
 <5.1.0.14.2.20040914184652.03e24de0@171.71.163.14> <20040914123951.GL4141@stingr.sgu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>, Paul P Komkoff Jr <i@stingr.net>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul P Komkoff Jr <i@stingr.net>
In-Reply-To: <20040914123951.GL4141@stingr.sgu.ru>
References: <5.1.0.14.2.20040914184652.03e24de0@171.71.163.14>
 <20040913051706.GB26337@stingr.sgu.ru>
 <20040911194108.GS28258@stingr.sgu.ru>
 <20040912170505.62916147.davem@davemloft.net>
 <20040913051706.GB26337@stingr.sgu.ru>
 <5.1.0.14.2.20040914184652.03e24de0@171.71.163.14>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 10:39 PM 14/09/2004, Paul P Komkoff Jr wrote:
>Replying to Lincoln Dale:
> > the logic is correct, but it may make sense to call the appropriate
> > netfilter hook again with the "unwrapped" GRE packet, as otherwise
> > packets-inside-GRE represent a possible security hole where one can inject
> > packets externally and bypass firewall rules.
>
> From what I observe, netfilter hooks *are* called for unwrapped packets.
>Either for usual IP packets  passed from GRE tunnel, or for demangled
>wccp packets.

you probably want to ensure that the order of netfilter events are:
   1. [packet comes in]
   2. netfilter INPUT
   3. [GRE decap]
   4. [addressed to us?]
       Yes => netfilter INPUT
       No => netfilter FORWARD

i don't think that both (2) and (4) are done.

also just a minor nit: not all WCCP needs to be GRE-encoded; on 
high-performance switch/router platforms, only a layer-2 rewrite of the dst 
MAC addr is used instead of a layer-3 GRE tunnel.  you may want the comment 
at line 609 to explicitly mention "WCCPv1 and WCCPv2 GRE Forwarding mode".


cheers,

lincoln.
