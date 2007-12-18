From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Tue, 18 Dec 2007 13:52:55 -0800
Message-ID: <OF87295D1E.4B69B8F8-ON882573B5.00755AB2-882573B5.0078619A@us.ibm.com>
References: <47683452.8080102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:50016 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598AbXLRVxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 16:53:04 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBILqxi0007257
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 16:52:59 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBILqxem121524
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 14:52:59 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBILqwK2001102
	for <netdev@vger.kernel.org>; Tue, 18 Dec 2007 14:52:58 -0700
In-Reply-To: <47683452.8080102@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote on 12/18/2007 12:57:54 PM:

> Trying to connect() to an IPv6 link-local multicast address by
> specifying the outgoing multicast interface doesn't work, you have to
> bind to a device first with an SO_BINDTODEVICE setsockopt() call.

        No, you simply have to specify sin6_scope_id for link-scope
addresses, like you do in unicast cases. Your patch requires them
to match (if specified), but I don't think IPV6_MULTICAST_IF should
override or require a match for a valid sin6_scope_id (or be an error).
        If I read it correctly, the existing code uses IPV6_MULTICAST_IF
if the sin6_scope_id is not set, otherwise honors the interface specified
in the connect. That seems like correct behaviour to me, and RFC 3493
doesn't address the relative precedence of the two that I see. This is
in the "linklocal" branch, and all unicast linklocal's require specifying
sin6_scope_id. Multicast doesn't if require a scope_id in the case where
you've done an IPV6_MULTICAST_IF, but it should still allow a different
scope_id when you have used IPV6_MULTICAST_IF.

        Do you have application code that you believe is correct that
doesn't work?

                                                                +-DLS

