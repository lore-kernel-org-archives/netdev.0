From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC PATCH 5/5] openvswitch: Interface with NAT.
Date: Wed, 21 Oct 2015 16:42:12 +0200
Message-ID: <20151021144212.GB31323@breakpoint.cc>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
 <1445379629-112880-5-git-send-email-jrajahalme@nicira.com>
 <20151021093459.GA31323@breakpoint.cc>
 <20151021113054.GB17991@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Jarno Rajahalme <jrajahalme@nicira.com>,
	netdev@vger.kernel.org, dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39898 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755055AbbJUOmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 10:42:16 -0400
Content-Disposition: inline
In-Reply-To: <20151021113054.GB17991@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@suug.ch> wrote:
> On 10/21/15 at 11:34am, Florian Westphal wrote:
> > Jarno Rajahalme <jrajahalme@nicira.com> wrote:
> > >  #define OVS_CS_F_REPLY_DIR         0x08 /* Flow is in the reply direction. */
> > >  #define OVS_CS_F_INVALID           0x10 /* Could not track connection. */
> > >  #define OVS_CS_F_TRACKED           0x20 /* Conntrack has occurred. */
> > > +#define OVS_CS_F_SRC_NAT           0x40 /* Packet's source address/port was
> > > +					   mangled by NAT. */
> > > +#define OVS_CS_F_DST_NAT           0x80 /* Packet's destination address/port
> > > +					   was mangled by NAT. */
> > 
> > I'm blind -- how does ovs deal with change of output device and the
> > ether dst mac as result of a l3 dst translation?
> 
> I assume you are referring to rewriting of L2 and the forwarding decision
> after NAT. As NAT is performed in combination with conntrack, the packet
> is recirculated and hits the flow table again after NAT. That 2nd
> stage flow must take are of performing L3 by rewriting L2, decrementing
> TTL, etc.

> Is this what you are referring to?

Yes, exactly, thanks for answering my question.

[ in classic bridge netfilter this requires route lookup & neigh stunts
  to deal with the consequences of dnat, i.e.

- route says dst is reachable via some other interface not part of
bridge
- route says that dst is localhost
- route says its on same bridge, but neigh has no idea what the new
dst mac address is,etc.

I was kinda disappointed to not see similar tur^W hacks ;)
