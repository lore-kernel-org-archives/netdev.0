From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: pull on receive skb may
 need to happen earlier
Date: Tue, 09 Jul 2013 08:47:20 +0100
Message-ID: <51DBDC2802000078000E37E2@nat28.tlf.novell.com>
References: <8511913.uMAmUdIO30@eistomin.edss.local>
 <20130517085923.GC14401@zion.uk.xensource.com>
 <51D57C1F.8070909@hunenet.nl>
 <20130704150137.GW7483@zion.uk.xensource.com>
 <51D6AED902000078000E2EA9@nat28.tlf.novell.com>
 <20130705145319.GB9050@zion.uk.xensource.com>
 <51DAA9B202000078000E3357@nat28.tlf.novell.com>
 <51DAE6CA02000078000E3566@nat28.tlf.novell.com>
 <1373296938.4979.111.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <ian.campbell@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>, <davem@davemloft.net>,
	"Dion Kant" <g.w.kant@hunenet.nl>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:43215 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753214Ab3GIHr0 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:6:1>);
	Tue, 9 Jul 2013 03:47:26 -0400
In-Reply-To: <1373296938.4979.111.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 08.07.13 at 17:22, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2013-07-08 at 15:20 +0100, Jan Beulich wrote:
> 
>> Okay, so with that done (see below) Dion is now seeing the
>> WARN_ON_ONCE(delta < len) in skb_try_coalesce() triggering. Of
>> course, with it having crashed before, it's hard to tell whether the
>> triggering now is an effect of the patch, or just got unmasked by it.
> 
> Please note this warning is not the sign of an error.

Thanks for pointing this out.

> It can be triggered because network stack (IP + TCP) had to reallocate
> skb->head to hold all the headers.
> 
> pskb_may_pull() doesn't change skb->truesize, for various reasons, so we
> can have a situation where the warning triggers.
> 
> For example, it can happen when drivers use a really small skb->head,
> like 64 bytes, as its not big enough to hold ethernet+IP+TCP headers.

We know from the crashes prior to the patch here that this is
exactly what is happening.

Jan
