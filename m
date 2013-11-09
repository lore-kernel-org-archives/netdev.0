From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netlink: fix netlink_ack with large messages
Date: Sat, 9 Nov 2013 19:03:53 +0100
Message-ID: <20131109180353.GA3715@localhost>
References: <9333f540a9b87adbdd15e274d12a9d60994fdb34.1383850578.git.jbenc@redhat.com>
 <20131108.150741.966018155704146843.davem@davemloft.net>
 <20131109000434.GD28793@casper.infradead.org>
 <20131109.000012.1393414533296613338.davem@davemloft.net>
 <527E3C17.1080508@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	jbenc@redhat.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36227 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753740Ab3KISD6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Nov 2013 13:03:58 -0500
Content-Disposition: inline
In-Reply-To: <527E3C17.1080508@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 09, 2013 at 08:43:51AM -0500, Jamal Hadi Salim wrote:
> On 11/09/13 00:00, David Miller wrote:
> 
> >The user has the message, they gave it to us in the sendmsg()
> >we are responding to.  We absolutely do not need to give it
> >to them again.
> >
> >If they care about referring to the contents of that message, they can
> >refer to it in their own copy and make sure they are really looking at
> >the same thing by comparing the sequence number in the netlink ACK to
> >the one they used in the netlink header they gave to the kernel in the
> >sendmsg() call.
> >
> >What happens now is pure duplication, and for such huge netlink
> >messages it's really not smart at all.
> >
> 
> for errors, we need to give the user something back. This has been the
> behavior for 80 years now. Giving them a HUGE message
> back is rediculuos(tm). Ive had enough of SCTP doing that.
> We need to cap it - sort of what ICMP does.
> ICMP caps at 64B; something like 128B is reasonable.

Personally, I have only used the sequence number to correlate the
original request with the ack reply, so I agree in that trimming it to
some reasonable amount of bytes like ICMP is the way to go. I prefer
if we select a large enough amount of bytes to avoid breaking backward
compatibility, eg. 128KB, since I'm not sure what kind of handling
others may have done of this.
