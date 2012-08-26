From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/19] netfilter: nf_conntrack_ipv6: improve fragmentation
 handling
Date: Sun, 26 Aug 2012 23:20:55 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208262318550.16771@stinky-local.trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>   
 <1344542943-11588-6-git-send-email-kaber@trash.net>   <1345190795.3069.228.camel@localhost>
  <Pine.GSO.4.63.1208181423050.17600@stinky-local.trash.net>
 <1345405069.3069.241.camel@localhost>  <Pine.GSO.4.63.1208192141570.3016@stinky-local.trash.net>
 <1345587697.3069.297.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Julian Anastasov <ja@ssi.bg>,
	Hans Schillstrom <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345587697.3069.297.camel@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Aug 2012, Jesper Dangaard Brouer wrote:

> On Sun, 2012-08-19 at 21:44 +0200, Patrick McHardy wrote:
>> On Sun, 19 Aug 2012, Jesper Dangaard Brouer wrote:
>>> On Sat, 2012-08-18 at 14:26 +0200, Patrick McHardy wrote:
> [...]
>
>>> Don't I need to load some of the helper modules, or just the
>>> nf_conntrack_ipv6 module, or perhaps only nf_defrag_ipv6 ?
>>
>> Not with the entire patchset, just IPv6 conntrack is enough. Aith IPv6 NAT
>> the first packet of a connection must always be defragemented, independant
>> of an assigned helper.
>
> When loading "nf_conntrack_ipv6" I run into issues.
>
> When sending a fragmented UDP packet.  With these patches, the IPVS
> stack will no longer see the fragmented packets, but instead see one
> large SKB.  This will trigger a MTU path check in e.g.
> ip_vs_dr_xmit_v6() and an ICMPv6 too big packet is send back.
>
>  IPVS: ip_vs_dr_xmit_v6(): frag needed
>
> Perhaps we could change/fix the MTU check in IPVS?
> (This would also solve issues I've seen with TSO/GSO frames, hitting
> this code path).

I guess this should use the same check as in IPv6 output, check
whether IP6CB(skb)->max_frag_size is != 0 and > MTU and only send
an ICMPv6 error in that case.
