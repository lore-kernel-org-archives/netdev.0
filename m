From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: suspicious unlikely usage in tcp_transmit_skb()
Date: Wed, 26 Apr 2006 00:26:31 -0700 (PDT)
Message-ID: <20060426.002631.107293234.davem@davemloft.net>
References: <20060425100149.636d6a1d@localhost.localdomain>
	<20060425.144649.129407913.davem@davemloft.net>
	<20060425151635.549d3400@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hzhong@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:25309
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750744AbWDZH0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 03:26:31 -0400
To: shemminger@osdl.org
In-Reply-To: <20060425151635.549d3400@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 25 Apr 2006 15:16:35 -0700

> On Tue, 25 Apr 2006 14:46:49 -0700 (PDT)
> "David S. Miller" <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@osdl.org>
> > Date: Tue, 25 Apr 2006 10:01:49 -0700
> > 
> > > >       # Hit    # miss Function:Filename@Line
> > > > !         0     50505 tcp_transmit_skb():net/ipv4/tcp_output.c@468
> >  ...
> > > How about just taking off the likely/unlikely in this case.
> > 
> > Why remove it when we'll now get a 50505 to 0 hit rate?
> 
> Depends on the data stream, but I guess if we are seeing high loss
> we really don't care about the CPU branch prediction.

I disagree, this is a hard error condition, and happens only when
af_ops->queue_xmit() cannot send the packet successfully.  Under
any normal circumstances whatsoever, it will succeed.

Are you actually looking at the right piece of code? :-)
