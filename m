From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: net: replace hooks in __netif_receive_skb (v4)
Date: Tue, 1 Jun 2010 09:10:04 -0700
Message-ID: <20100601091004.7885cd8c@nehalam>
References: <20100527180813.GA3714@psychotron.redhat.com>
	<20100527130822.02cb1661@nehalam>
	<20100528055154.GB2823@psychotron.redhat.com>
	<20100528061241.GC2823@psychotron.redhat.com>
	<1275030163.2650.3.camel@edumazet-laptop>
	<20100528073345.GD2823@psychotron.redhat.com>
	<20100601082805.1c84b16d@nehalam>
	<20100601154106.GA4929@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	eric.dumazet@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44958 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757102Ab0FAQKL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 12:10:11 -0400
In-Reply-To: <20100601154106.GA4929@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Jun 2010 17:41:07 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> Actually, I'm not happy about this (reducing to only one hook) and for two
> reasons:
> 
> 1) I think it's a good behaviour to "mask" one handler by another in case device
> is for example used for macvlan and then added to bridge. Because when it's
> again removed from the bridge, the original functionality is restored. And also,
> this would be consistent with the current behaviour.
> 
> 2) I would imagine a situation, when multiple handers are needed in cascade.
> Actually I'm working on a virtual device draft which uses two handlers, although
> in corner situation.
> 
> Regards,
> 	Jirka

I don't like it because:

1) Adding macvlan to bridge makes no sense. The bridge is already in promicious mode.

2) I don't like to see functionality added when it is not needed.

3) The extra overhead of traversing list causes more cache activity in extreme
   hot path.

Wait and add the multiple handlers when your code is included.

-- 
http://www.extremeprogramming.org/rules/early.html
