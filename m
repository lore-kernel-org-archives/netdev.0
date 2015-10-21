From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 5/5] openvswitch: Interface with NAT.
Date: Wed, 21 Oct 2015 13:30:54 +0200
Message-ID: <20151021113054.GB17991@pox.localdomain>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
 <1445379629-112880-5-git-send-email-jrajahalme@nicira.com>
 <20151021093459.GA31323@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarno Rajahalme <jrajahalme@nicira.com>, netdev@vger.kernel.org,
	dev@openvswitch.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38614 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801AbbJULa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 07:30:56 -0400
Received: by wicll6 with SMTP id ll6so69657150wic.1
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 04:30:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20151021093459.GA31323@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/15 at 11:34am, Florian Westphal wrote:
> Jarno Rajahalme <jrajahalme@nicira.com> wrote:
> >  #define OVS_CS_F_REPLY_DIR         0x08 /* Flow is in the reply direction. */
> >  #define OVS_CS_F_INVALID           0x10 /* Could not track connection. */
> >  #define OVS_CS_F_TRACKED           0x20 /* Conntrack has occurred. */
> > +#define OVS_CS_F_SRC_NAT           0x40 /* Packet's source address/port was
> > +					   mangled by NAT. */
> > +#define OVS_CS_F_DST_NAT           0x80 /* Packet's destination address/port
> > +					   was mangled by NAT. */
> 
> I'm blind -- how does ovs deal with change of output device and the
> ether dst mac as result of a l3 dst translation?

I assume you are referring to rewriting of L2 and the forwarding decision
after NAT. As NAT is performed in combination with conntrack, the packet
is recirculated and hits the flow table again after NAT. That 2nd
stage flow must take are of performing L3 by rewriting L2, decrementing
TTL, etc.

Is this what you are referring to?
