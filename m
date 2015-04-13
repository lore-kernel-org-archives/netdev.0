From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Sun, 12 Apr 2015 21:14:21 -0400 (EDT)
Message-ID: <20150412.211421.1771298417488412635.davem@davemloft.net>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
	<20150410132205.GF23070@casper.infradead.org>
	<20150410200901.GB5968@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netfilter-devel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150410200901.GB5968@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 10 Apr 2015 22:09:01 +0200

> On Fri, Apr 10, 2015 at 02:22:05PM +0100, Thomas Graf wrote:
>> On 04/10/15 at 02:15pm, Pablo Neira Ayuso wrote:
>> > This patchset adds the Netfilter hook at the ingress path, in a per-device
>> > fashion. This also comes with the new nf_tables 'netdev' family support to
>> > provide access to users to the existing nf_tables features. This includes the
>> > transactional netlink API and the enhanced set infrastructure.  Several patches
>> > come in first place to prepare this support, including the refactoring of
>> > __netif_receive_skb_core() to accomodate the new hook.
>> 
>> Is the goal to eventually replace ebtables with this?
> 
> No, nftables comes with a bridge family that will eventually replace
> ebtables.

It's always been the case that if you want to do L2 or lower level
stuff, you use the ingress classifier, packet actions, and qdiscs.

If you want to do higher level things, NF hooks provide that facility.

The only example I've seen is packet counting, and one could do that
just as easily with the ingress qdisc.

So given what I've been shown so far I'm very far from convinced that
this new hook in an already over polluted, most critical of all
critical code paths, is justified at all.
