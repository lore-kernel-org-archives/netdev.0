From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] bridge: allow forwarding some link local frames
Date: Mon, 17 Oct 2011 08:18:26 -0700
Message-ID: <20111017081826.25888f1f@nehalam.linuxnetplumber.net>
References: <20111004041444.793960297@vyatta.com>
	<20111004041509.292932641@vyatta.com>
	<CAF5U64AYRhZ1e0=-RhSemgaOnewTQSpAoRY2FUrFr252PG98Pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ed Swierk <eswierk@bigswitch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34583 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487Ab1JQPS3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 11:18:29 -0400
In-Reply-To: <CAF5U64AYRhZ1e0=-RhSemgaOnewTQSpAoRY2FUrFr252PG98Pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Oct 2011 07:35:53 -0700
Ed Swierk <eswierk@bigswitch.com> wrote:

> Why is forwarding LLDP (01-80-C2-00-00-0E) frames forbidden? I'm
> testing LLDP in a virtual topology and need the bridge to forward
> them.
> 
> If we're worried about standards, there is justification for allowing
> forwarding of LLDP frames. 802.1d-2005 specifies two classes of
> bridge, customer (C-VLAN) and provider (S-VLAN). Customer bridge is
> just new terminology for what was previously just called an
> 802.1d-compliant bridge, while provider bridge is a new class that
> transparently forwards certain control frames.


Because in current 802.1Q (2005) standard there explicit language
that LLDP should not be forwarded. In Section 7.5

	Frames that carry control information to determine the active
	topology and current extent of each VLAN, i.e., spanning tree
	and GVRP BPDUs, and frames from other link constrained
	protocols, such as EAPOL and LLDP, are not forwarded.
	Permanently configured static entries in the filtering database
	(8.2, 8.3, and 8.12) ensure that such frames are discarded by
	the Forwarding Process (8.6).

> The only MAC addresses that are not supposed to be forwarded by either
> customer or provider bridges are:
> 
> IEEE 802.3 Full Duplex PAUSE operation (01-80-C2-00-00-01)
> IEEE 802.3 Slow_Protocols_Multicast address (01-80-C2-00-00-02)
> IEEE 802.1X PAE address (01-80-C2-00-00-03)
> Provider Bridge Group Address (01-80-C2-00-00-08)
>
> Customer bridges are also not supposed to forward these addresses:
> 
> Bridge Group Address (01-80-C2-00-00-00)
> Provider Bridge GVRP Address (01-80-C2-00-00-0D)
> IEEE 802.1AB Link Layer Discovery Protocol multicast address (01-80-C2-00-00-0E)
> 
> My application requires a bridge between a pair of interfaces that
> forwards (at least) LLDP frames; call this a provider bridge if you
> care about standards conformance. It sounds like others require
> forwarding 802.1X PAE frames, which appears non-conformant in any
> case.
> 
> Standards aside, given that the default behavior is safe and that
> /sys/class/net/brX/bridge/group_fwd_mask is unlikely to be modified by
> accident by a casual user, can we just remove the
> BR_GROUPFWD_RESTRICTED mask and allow users to forward whatever they

Since EAPOL is allowed, and there is a use case for LLDP, allowing
that is probably okay.

I would prefer not to let user break standards by default. You of course are
free to compile what ever you want
