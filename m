From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [v4 PATCH 1/2] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Thu, 1 Dec 2011 01:52:36 +0100
Message-ID: <201112010152.36659.hans@schillstrom.com>
References: <hr62jai.42522fc2b4c8846204d05566f5c6b926@obelix.schillstrom.com> <4ED64B5E.2030705@trash.net> <20111130182815.GC20336@1984>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw21.han.skanova.net ([81.236.55.21]:42701 "EHLO
	smtp-gw21.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380Ab1LAAwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 19:52:39 -0500
In-Reply-To: <20111130182815.GC20336@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday, November 30, 2011 19:28:15 Pablo Neira Ayuso wrote:
> On Wed, Nov 30, 2011 at 04:27:26PM +0100, Patrick McHardy wrote:
> > On 11/28/2011 10:36 AM, Hans Schillstrom wrote:
> > >>If you don't want to use conntrack in your setup and you want to handle
> > >>fragments, then you have to configure HMARK to calculate the hashing
> > >>based on the network addresses. If you want to fully support fragments,
> > >>then enable conntrack and you can configure HMARK to calculate the
> > >>hashing based on network address + transport bits.
> > >>
> > >>Fix this by removing the fragmentation handling, then assume that
> > >>people can select between two hashing configuration for HMARK. One
> > >>based for network address which is fragment-safe, one that uses the
> > >>transport layer information, that requires conntrack. Otherwise, I
> > >>don't see a sane way to handle this situation.
> > >Correct me if I'm wrong here,
> > >If conntrack is enabled hmark don't see the packet until it is reassembled and
> > >in that case the fragmentation header is removed.
> > >
> > >So, with conntrack HMARK will operate on full packets not fragments
> > >without conntrack ports will not be used on any fragment
> > 
> > Correct.
> 
> To complete what Patrick said. They are collected but not linearized.
> That's why you have to use skb_header_pointer.
OK, thanks
I'll will do that.

> 
> > You don't necessarily need conntrack for defragmentation though,
> > we've moved defragmentation to a seperate module for TPROXY. You
> > can depend on that and get defragmentation without full
> > connection tracking.
> 
> Indeed, I missed this. That way you can skip conntrack but solving the
> broken fragments handling.

In a cluster with inputs on many different blades (with a Virtual IP address) you can
receive the fragments on different blades and in that case there should not be any
defrag in that node. HMARK will just produce the same fw-mark for all fragments.

In our case defrag will happens in next hop i.e. before going into IPVS.

As mention earlier, this needs to be documented better.
I will add this to the man page.

Thanks
Hans
