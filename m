From: Ed Swierk <eswierk@bigswitch.com>
Subject: Re: [PATCH 2/2] bridge: allow forwarding some link local frames
Date: Mon, 17 Oct 2011 07:35:53 -0700
Message-ID: <CAF5U64AYRhZ1e0=-RhSemgaOnewTQSpAoRY2FUrFr252PG98Pw@mail.gmail.com>
References: <20111004041444.793960297@vyatta.com> <20111004041509.292932641@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60008 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756024Ab1JQOge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 10:36:34 -0400
Received: by vws1 with SMTP id 1so2603216vws.19
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 07:36:33 -0700 (PDT)
In-Reply-To: <20111004041509.292932641@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Why is forwarding LLDP (01-80-C2-00-00-0E) frames forbidden? I'm
testing LLDP in a virtual topology and need the bridge to forward
them.

If we're worried about standards, there is justification for allowing
forwarding of LLDP frames. 802.1d-2005 specifies two classes of
bridge, customer (C-VLAN) and provider (S-VLAN). Customer bridge is
just new terminology for what was previously just called an
802.1d-compliant bridge, while provider bridge is a new class that
transparently forwards certain control frames.

The only MAC addresses that are not supposed to be forwarded by either
customer or provider bridges are:

IEEE 802.3 Full Duplex PAUSE operation (01-80-C2-00-00-01)
IEEE 802.3 Slow_Protocols_Multicast address (01-80-C2-00-00-02)
IEEE 802.1X PAE address (01-80-C2-00-00-03)
Provider Bridge Group Address (01-80-C2-00-00-08)

Customer bridges are also not supposed to forward these addresses:

Bridge Group Address (01-80-C2-00-00-00)
Provider Bridge GVRP Address (01-80-C2-00-00-0D)
IEEE 802.1AB Link Layer Discovery Protocol multicast address (01-80-C2-00-00-0E)

My application requires a bridge between a pair of interfaces that
forwards (at least) LLDP frames; call this a provider bridge if you
care about standards conformance. It sounds like others require
forwarding 802.1X PAE frames, which appears non-conformant in any
case.

Standards aside, given that the default behavior is safe and that
/sys/class/net/brX/bridge/group_fwd_mask is unlikely to be modified by
accident by a casual user, can we just remove the
BR_GROUPFWD_RESTRICTED mask and allow users to forward whatever they
want?

--Ed
