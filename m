From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Wed, 19 Dec 2007 10:18:24 -0800
Message-ID: <OF367F9F64.87ED9167-ON882573B6.0063B893-882573B6.0064BE22@us.ibm.com>
References: <476936D5.4070606@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:50899 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbXLSSUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 13:20:46 -0500
In-Reply-To: <476936D5.4070606@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vladislav.yasevich@hp.com> wrote on 12/19/2007 07:20:53 AM:

> But this still requires either a SO_BINDTODEVICE or sin6_scope_id.  This
> means the an application can call BINDTODEVICE(eth0), MULTICAST_IF(eth1)
> issue a connect on a UDP socket an succeed?  Seems wrong to me.
> 
> Can you check section 6.7 of RFC 3542.

        No, it requires one of SO_BINDTODEVICE, sin6_scope_id, or 
IPV6_MULTICAST_IF.
If you do an SO_BINDTODEVICE(eth0) and then an IPV6_MULTICAST_IF(eth1), 
the
IPV6_MULTICAST_IF will fail in setsockopt (EINVAL), because it requires a 
match
for bound sockets. I'm not sure if SO_BINDTODEVICE resets mcast_oif if you 
do
them in the reverse order, but that would be a bug in SO_BINDTODEVICE.
        The precedence order as implemented already is:

                SO_BINDTODEVICE is highest and always wins
                sin6_scope_id next
                IPV6_MULTICAST_IF

and the existing code has the rule that all link-local addresses require a
sin6_scope_id. The change (intended) is to relax the sin6_scope_id rule 
only
for link-local multicasts that have done either an SO_BINDTODEVICE or
IPV6_MULTICAST_IF already.

 +-DLS

