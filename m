From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v12 06/11] vxlan: add ipv6 support
Date: Sat, 31 Aug 2013 10:27:26 -0700
Message-ID: <20130831102726.21896150@nehalam.linuxnetplumber.net>
References: <1377927878-23975-1-git-send-email-amwang@redhat.com>
	<1377927878-23975-7-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:53775 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754332Ab3HaR13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 13:27:29 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb10so3525153pad.23
        for <netdev@vger.kernel.org>; Sat, 31 Aug 2013 10:27:29 -0700 (PDT)
In-Reply-To: <1377927878-23975-7-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 31 Aug 2013 13:44:33 +0800
Cong Wang <amwang@redhat.com> wrote:

> +#if IS_ENABLED(CONFIG_IPV6)
> +	} else {
> +		ipv6_stub->ipv6_sock_mc_join(sk, ifindex,
> +					     &ip->sin6.sin6_addr);
> +#endif

This isn't safe against IPv6 module getting unloaded. You either
have to figure out a reference count method, or disable IPv6
module unload.

Since it can only be forced unload anyway, I still argue
it should just be disabled (by removing the module exit hook
and code).
