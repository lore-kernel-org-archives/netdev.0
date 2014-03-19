From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with no
 group
Date: Wed, 19 Mar 2014 14:28:11 -0600
Message-ID: <OFA5522ACE.EF0D1366-ON87257CA0.00707184-87257CA0.00707189@us.ibm.com>
References: <20140319.154649.1043650085697557640.davem@davemloft.net>,
	<1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>	<OFEB1030F8.C147FA77-ON87257C9F.005CF370-87257C9F.005CF375@us.ibm.com>
	<CAF1J0HOTLvyaWdmYLGLPn9AJLR6rQr4fk8EVFSzv5sckLuBwvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mike.rapoport@ravellosystems.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:42001 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121AbaCSU2P convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 16:28:15 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 19 Mar 2014 14:28:15 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C5BA01FF001A
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 14:28:12 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2JKRdVl8257966
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 21:27:39 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2JKSB0U008331
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 14:28:12 -0600
In-Reply-To: <20140319.154649.1043650085697557640.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----David Miller <davem@davemloft.net> wrote: -----

>The way I read things, we would receive packets unconditionally in
>the
>pre-ipv6-support code. So we have to keep doing so.

I never tried it, but as there are IP-version-specific processing (the
whole reason we need to check to support both), I'd expect
that before the v6 support patch, v6-encapsulated packets would have
been dropped, or at least mishandled. We accepted all v4 packets,
because v4 is all that was supported.

I think the biggest risk is that someone who is only using or
caring about v4 will have a security vulnerability because
someone can drop packets on the virtual network via v6--
something likely unexpected on an otherwise v4-only network.

When the default_dst is a v4 multicast, or saddr is set to be
a v4 address, we can't have 2-way communication with other
segments using v6, and similary if they are v6, a v4-endpoint
can't join the v6-multicast group.

I think mixing protocols only makes sense when saddr is not
set at all and when default_dst is not a multicast address.
The other possibilities lead to unexpected problems, and
potential mischief.

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0+-DLS
