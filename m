From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: Possible regression in __netif_receive_skb() between 2.6.38-rc7
 and net-next-2.6
Date: Sat, 5 Mar 2011 23:09:39 +0100
Message-ID: <20110305220938.GK8573@psychotron.redhat.com>
References: <4D72AB79.3000605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Patrick Mc Hardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64989 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197Ab1CEWJp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 17:09:45 -0500
Content-Disposition: inline
In-Reply-To: <4D72AB79.3000605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Mar 05, 2011 at 10:30:33PM CET, nicolas.2p.debian@gmail.com wrote:
>Hi,
>
>Comparing __netif_receive_skb() between 2.6.38-rc7 and net-next-2.6,
>I noticed an important difference: The ptype_base loop used to
>deliver to orig_dev and this is not true anymore.

I believe this is adressed by submitted patch " net: allow handlers to
be processed for orig_dev"


>
>[Note that this is unrelated to Jiri's today's patch that remove the
>orig_dev parameter to protocol handler].
>
>Imagine the following simple setup:
>
>eth0 -> bond0
>
>- A packet handler registered on eth0, with ptype->type == NULL will
>receive the packet, because it will be delivered in the ptype_all
>loop, which is inside the another_round loop.
>- The same packet handler, registered on eth0, but with ptype->type
>!= NULL won't receive the packet, because the ptype_base loop doesn't
>deliver to orig_dev anymore.
>
>I think this can lead to a regression for user space: an application
>using af_packet to listen to eth0 will receive the packet flow if the
>registered protocol is NULL, but won't receive anything if the
>registered protocol is not NULL.
>
>Can someone confirm?
>
>	Nicolas.
