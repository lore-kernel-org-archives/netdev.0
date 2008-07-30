From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: send correct MTU value in PMTU (revised)
Date: Wed, 30 Jul 2008 14:10:17 -0700
Message-ID: <20080730141017.0000aceb@extreme>
References: <200807301937.m6UJbZaR012427@imap1.linux-foundation.org>
	<20080730133259.576e0041@extreme>
	<20080730135008.4f98f5ee.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	simon.wunderlich@s2003.tu-chemnitz.de, siwu@hrz.tu-chemnitz.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36665 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758628AbYG3VK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 17:10:56 -0400
In-Reply-To: <20080730135008.4f98f5ee.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008 13:50:08 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 30 Jul 2008 13:32:59 -0700
> Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> 
> > When bridging interfaces with different MTUs, the bridge correctly chooses
> > the minimum of the MTUs of the physical devices as the bridges MTU.  But
> > when a frame is passed which fits through the incoming, but not through
> > the outgoing interface, a "Fragmentation Needed" packet is generated.
> > 
> > However, the propagated MTU is hardcoded to 1500, which is wrong in this
> > situation.  The sender will repeat the packet again with the same frame
> > size, and the same problem will occur again.
> > 
> > Instead of sending 1500, the (correct) MTU value of the bridge is now sent
> > via PMTU.  To achieve this, the corresponding rtable structure is stored
> > in its net_bridge structure.
> > 
> > Modified to get rid of fake_net_device as well.
> > 
> > Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> um.
> 
> a) Why was this To:me and not To:davem?  I'm trying to get rid of it ;)
> 
> b) The way you sent this email indicates that you wrote the patch. 
>    To preserve correct attribution, please put a From: line right at the
>    top of the changelog.
> 
> c) For the record, here are the changes which you (I assume) made to
>    Simon's patch:
> 
>    (br_netfilter_rtable_init() no longer initialises
>    fake_rtable.rt_flags.  Deliberate?)
> 

a) didn't want you holding onto old version, and it leaking upstream.
b) didn't know how to spoof git's attribution
c) fake_rtable gets initialized to zero already.
   Since it is part of bridge structure and the whole bridge structure
   is the private part of the bridge pseudo network device which
   is initialized to zero as part of alloc_netdev.


