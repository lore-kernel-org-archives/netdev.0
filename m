From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] openvswitch: Do not set skb ignore_df
Date: Fri, 2 Jan 2015 20:09:09 +0000
Message-ID: <20150102200909.GB30942@casper.infradead.org>
References: <1420223248-1681-1-git-send-email-pshelar@nicira.com>
 <CAEP_g=-dmtKbC+GkOsr1Z+gUB6Q0noFP_O5PhXmhs_w3j0BV0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59687 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbbABUJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 15:09:13 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=-dmtKbC+GkOsr1Z+gUB6Q0noFP_O5PhXmhs_w3j0BV0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/02/15 at 03:03pm, Jesse Gross wrote:
> On Fri, Jan 2, 2015 at 1:27 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> > Tunnel transmit code clear this bit, so setting ignore_df has
> > no effect.
> >
> > Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> 
> Is it actually right for the bit to be cleared though? As discussed in
> the previous thread on tunnel MTU handling, I think that fragmentation
> should be done as a very last resort.

Agreed. The source VXLAN VTEP should not fragment at all. I think we
need a separate skb_scrub_packet() for encaps at this point. Some of
the assumptions made for namespace handover do not apply.
