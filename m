From: Patrick McHardy <kaber@trash.net>
Subject: Re: kernel BUG at net/core/skbuff.c:1048!
Date: Sun, 20 Oct 2013 19:33:12 +0100
Message-ID: <20131020183312.GB16002@macbook.localnet>
References: <524E8BFB.9080708@icts.kuleuven.be>
 <20131005100105.GA2457@macbook.localnet>
 <20131020182523.GF27787@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Wim Vandersmissen <Wim.Vandersmissen@icts.kuleuven.be>,
	netdev@vger.kernel.org, kernelspam@bofh.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64280 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454Ab3JTSdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 14:33:19 -0400
Content-Disposition: inline
In-Reply-To: <20131020182523.GF27787@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 20, 2013 at 08:25:23PM +0200, Hannes Frederic Sowa wrote:
> Hi Patrick!
> 
> On Sat, Oct 05, 2013 at 11:01:05AM +0100, Patrick McHardy wrote:
> > On Fri, Oct 04, 2013 at 11:35:55AM +0200, Wim Vandersmissen wrote:
> > > Hi,
> > > 
> > > Got the following BUG when using ipv6 netfilter/conntrack/ipv6
> > > forwarding and traffic flowing.
> > > 
> > > No issues in 3.4.x, but triggered in 3.10.x (introduced in 3.7)
> > 
> > Please also send me your 3.10.x config and the ip6tables rules you're
> > using.
> > 
> > Are you actually using IPv6 NAT? 
> 
> Maybe the same bug was hit by someone else and was reported in kernel
> bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=63331
> 
> I added him in Cc.

Thanks, didn't really get to it yet. The problem is obviously that we're
rerouting the individual fragments, during which their headroom gets
expanded while a reference to them is held by the reassembled skb. Just
not sure yet how to fix it.
