From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] [NEIGH] neighbour table configuration and
	statistics via rtnetlink
Date: Fri, 27 May 2005 07:14:24 -0400
Message-ID: <1117192464.6688.3.camel@localhost.localdomain>
References: <20050526185306.GW15391@postel.suug.ch>
	 <20050526185526.GZ15391@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050526185526.GZ15391@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-26-05 at 20:55 +0200, Thomas Graf wrote:
> To retrieve the neighbour tables send RTM_GETNEIGHTBL with the
> NLM_F_DUMP flag set. Every neighbour table configuration is
> spread over multiple messages to avoid running into message
> size limits on systems with many interfaces. The first message
> in the sequence transports all not device specific data such as
> statistics, configuration, and the default parameter set.
> This message is followed by 0..n messages carrying device
> specific parameter sets. They all share the same value for
> Although the ordering should be sufficient, NDTA_NAME can be
> used to identify sequences. The initial message can be identified
> by checking for NDTA_CONFIG. The device specific messages do
> no contain this TLV but have NDTPA_IFINDEX set to the
> corresponding interface index.
> 
> To change neighbour table attributes, send RTM_SETNEIGHTBL
> with NDTA_NAME set. Changeable attribute include NDTA_THRESH[1-3],
> NDTA_GC_INTERVAL, and all TLVs in NDTA_PARMS unless marked
> otherwise. Device specific parameter sets can be changed by
> setting NDTPA_IFINDEX to the interface index of the corresponding
> device.

It would have been better, IMO, to just work on a generic idev/devinet
retrieval and setting instead of one component (as in ARP in this
case). 

cheers,
jamal
