From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 19/29] net: vrf: Add vrf context to skb
Date: Thu, 05 Feb 2015 21:54:30 -0600
Message-ID: <878ugbwv7t.fsf@x220.int.ebiederm.org>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
	<1423100070-31848-20-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35915 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbbBFD5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 22:57:43 -0500
In-Reply-To: <1423100070-31848-20-git-send-email-dsahern@gmail.com> (David
	Ahern's message of "Wed, 4 Feb 2015 18:34:20 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsahern@gmail.com> writes:

> On ingress skb's inherit vrf context from the net_device. For TX skb's
> inherit the vrf context from the socket originating the packet. Update
> SKB related net_ctx macros to set vrf.

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

As I recall we had the conversation about modifying  struct sk_buff when
implementing network namespaces and it turns out it is a no go.  It adds
too much overhead.  As I recall skbs as they are on the fastpath are
things we want to make smaller.

> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---
>  include/linux/skbuff.h   |  7 ++++---
>  include/net/sock.h       |  2 ++
>  include/net/tcp.h        |  1 +
>  net/core/dev.c           |  1 +
>  net/core/fib_rules.c     |  2 ++
>  net/core/neighbour.c     |  2 ++
>  net/core/skbuff.c        | 12 ++++++++++++
>  net/ipv4/devinet.c       |  2 ++
>  net/ipv4/icmp.c          |  2 +-
>  net/ipv4/ip_output.c     |  2 ++
>  net/ipv4/syncookies.c    |  1 +
>  net/ipv4/tcp_ipv4.c      |  3 ++-
>  net/netlink/af_netlink.c | 12 ++++++++++++
>  13 files changed, 44 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index a5dfef469d07..bdbee41e8032 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -522,6 +522,7 @@ struct sk_buff {
>  	};
>  	struct sock		*sk;
>  	struct net_device	*dev;
> +	__u32			vrf;
>  
>  	/*
>  	 * This is the control buffer. It is free to use for every
