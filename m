From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v5] xen-netback: fix fragment detection
 in checksum setup
Date: Wed, 11 Dec 2013 09:47:50 +0000
Message-ID: <1386755270.30271.5.camel@kazak.uk.xensource.com>
References: <1386092369-13618-1-git-send-email-paul.durrant@citrix.com>
	 <52A74B56020000780010BFB9@nat28.tlf.novell.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD01ACF1F@AMSPEX01CL01.citrite.net>
	 <1386695522.30495.349.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Durrant <Paul.Durrant@citrix.com>,
	Jan Beulich <JBeulich@suse.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	David Miller <davem@davemloft.net>,
	xen-devel <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:19347 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774Ab3LKJrx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Dec 2013 04:47:53 -0500
In-Reply-To: <1386695522.30495.349.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-10 at 09:12 -0800, Eric Dumazet wrote:
> On Tue, 2013-12-10 at 16:24 +0000, Paul Durrant wrote:
> 
> > Yes, I guess that's true but if we decide to pull up at all then is it harmful to pull more than we absolutely need?
> 
> Pulling too many bytes might hurt aggregation.
> 
> When one skb is merged to another one (skb_try_coalesce()), if you have
> payload in skb->head, we cannot free the head, and need one additional
> 'frag'

Does that ever happen to skb's which are received by a NIC and passed up
to the network stack (including forwarding by bridging of netfilter)? I
thought this path only happened for locally generated traffic.

If it can happen for received skb's then that seems like a pretty solid
reason not to over estimate in the pull up phase.

Ian.
