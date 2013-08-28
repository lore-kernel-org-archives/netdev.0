From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v10 03/11] ipv6: export a stub for IPv6 symbols
 used by vxlan
Date: Wed, 28 Aug 2013 09:12:08 -0700
Message-ID: <20130828091208.4bcaedcf@nehalam.linuxnetplumber.net>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
	<1377667379-2315-4-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:42634 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524Ab3H1QMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 12:12:12 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so6490017pdj.32
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 09:12:11 -0700 (PDT)
In-Reply-To: <1377667379-2315-4-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Aug 2013 13:22:51 +0800
Cong Wang <amwang@redhat.com> wrote:

> +struct ipv6_stub {
> +	int (*ipv6_sock_mc_join)(struct sock *sk, int ifindex,
> +				 const struct in6_addr *addr);
> +	int (*ipv6_sock_mc_drop)(struct sock *sk, int ifindex,
> +				 const struct in6_addr *addr);
> +	int (*ipv6_dst_lookup)(struct sock *sk, struct dst_entry **dst,
> +				struct flowi6 *fl6);
> +	void (*udpv6_encap_enable)(void);
> +};
> +extern const struct ipv6_stub *ipv6_stub __read_mostly;
> +

Since IPv6 really can't ever be safely unloaded. why not:
 * admit that, and get rid of ipv6_module exit.
 * then this stub can be a static const table.

You see virtual function tables that are writeable are potential malware
targets, although eliminating all of them is impossible, I hate to
see adding new ones.
