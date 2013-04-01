From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch net-next v1 3/4] vxlan: add ipv6 support
Date: Mon, 1 Apr 2013 11:19:10 -0400
Message-ID: <OF5EB046E4.6295C3A5-ON85257B40.00537077-85257B40.00542577@us.ibm.com>
References: <1364708625-29063-1-git-send-email-amwang@redhat.com> <1364708625-29063-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:36898 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758665Ab3DAPcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 11:32:11 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 1 Apr 2013 09:32:10 -0600
In-Reply-To: <1364708625-29063-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 03/31/2013 01:43:44 AM:
 
> +struct vxlan_ip {
> +   union {
> +      __be32  ip4;
> +#if IS_ENABLED(CONFIG_IPV6)
> +      struct in6_addr ip6;
> +#endif
> +   };
> +   __be16          proto;
> +};
> +

        This looks suspiciously like a sockaddr. sockaddr_storage is
much bigger than you need, but you could just make it a sockaddr_in6
and cast it to sockaddr_in when needed, make it sockaddr_in6 and use
V4_MAPPED addresses for v4, or make it a union of sockaddr_in and
sockaddr_in6, or have a buffer the size of sockaddr_in6 and use it
as a sockaddr to determine the family, then go from there.
        I think anything along those lines is better than a new variant
with the same functionality of sockaddr that isn't an overlay of a
sockaddr.

                                                        +-DLS
