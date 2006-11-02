From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 6/6] IPv6: Fix infinite loop if no matching IPv6 tunnel
 found
Date: Thu, 02 Nov 2006 23:18:10 +0900 (JST)
Message-ID: <20061102.231810.119656005.yoshfuji@linux-ipv6.org>
References: <4549D8E7.1040409@tcs.hut.fi>
	<20061102.215900.15793371.yoshfuji@linux-ipv6.org>
	<4549EFA7.50004@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:13067 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1752558AbWKBOPZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 09:15:25 -0500
To: vnuorval@tcs.hut.fi
In-Reply-To: <4549EFA7.50004@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4549EFA7.50004@tcs.hut.fi> (at Thu, 02 Nov 2006 15:16:23 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> On 11/02/06 14:59, YOSHIFUJI Hideaki wrote:
> > In article <4549D8E7.1040409@tcs.hut.fi> (at Thu, 02 Nov 2006 13:39:19 +0200), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
> > 
> >>  	read_unlock(&ip6ip6_lock);
> >> -	return 1;
> >> -
> >> +	icmpv6_send(skb, ICMPV6_DEST_UNREACH,
> >> +		    ICMPV6_ADDR_UNREACH, 0, skb->dev);
> >>  discard:
> > 
> > I'd argue this.  We probably should not send back any ICMPv6 packets 
> > to the original sender in this case to avoid DoS.
> 
> Sorry, I don't follow you. I don't see the DoS scenario here (after we
> apply the patch, that is ;-).

Well, leaving aside whether sending icmpv6 is good thing (*),
the code for sending icmpv6 was moved from ip6_tunnel.c
to tunnel6.c by commit-id 50fba2aa7cefa6b0e1768cb350c9e69042320c03
by Herbert.

The ip6_tunnel.c change that Herbert made does not seem consistent
with ipip.c change.  To fix your issue the appropriate change is just
fall through to discard section, as we're doing for ipip.c.

Please do not re-add sending icmpv6 logic here.
If you DO think it is appropriate, please fix other codes
such as ipip.c, and your comment.

*: As far as I remember, *BSD*s do not send icmpv6
   in this case.
   Anyway, I'd talk to people at ietf next week.

--yoshfuji
