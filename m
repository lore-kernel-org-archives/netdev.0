From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch net-next v1 3/4] vxlan: add ipv6 support
Date: Tue, 2 Apr 2013 09:13:35 -0400
Message-ID: <OF204908E6.65D34E4B-ON85257B41.00463F2F-85257B41.0048A60B@us.ibm.com>
References: <1364708625-29063-1-git-send-email-amwang@redhat.com>		<1364708625-29063-3-git-send-email-amwang@redhat.com>
	 <OF5EB046E4.6295C3A5-ON85257B40.00537077-85257B40.00542577@us.ibm.com>	 <20130401.130223.1527520446382659798.davem@davemloft.net>
	 <OF1E30BC31.571FBD44-ON85257B40.005F5AF2-85257B40.0063627F@us.ibm.com> <1364867203.17029.7.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, stephen@networkplumber.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:53346 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760189Ab3DBNN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 09:13:57 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 2 Apr 2013 07:13:56 -0600
In-Reply-To: <1364867203.17029.7.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> wrote on 04/01/2013 09:46:43 PM:

> Well, besides avoid redefining another type, what else could we gain by
> using sockaddr_in6?

        The gain is code readability. If you have a type that's
already defined and used throughout the network code, someone
trying to understand your code won't need to look up the type
and details to figure it out and modify it.

> Look, we would have "vip->vip_sin.sin_addr.s_addr" instead of
> "ipa->ip4", much longer than the current one... 
> 
> So why defining a shorter and less complex struct matters?
> 
> 

        Because you have entire sections of nearly duplicated
code that handle IPv4 alone or IPv6 alone. That's a maintenance
issue over time because future changes need to happen in 2
separate places and are more likely to be missed in one or
not replicated identically.
        Using sockaddrs, the field containing an address is
the same (e.g., "gaddr" or "dst") whether it is v4 or v6
because the structure self-identifies the address format
by the address family. So, you can have common code for
either address family -- "vxlan->gaddr = group;" or similar--
and you only have family-specific code where there is a
difference between the families.
        VXLAN is an in-kernel client and server and like its
user-space counterparts, you can write a v4-only implementation
and a v6-only implementation separately, or you can use common code
for both with generic addresses. Using common code is usually
easier to understand, modify and debug.

                                                        +-DLS
