From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v6 net-next 09/14] ip6_tun: Add infrastructure for doing encapsulation
Date: Mon, 16 May 2016 15:25:06 -0700
Message-ID: <CAKgT0UcKFEB6oPXtVQsQK0qSCRNRhxs4juvcMHh_1x8bRCPaXQ@mail.gmail.com>
References: <1463434389-314297-1-git-send-email-tom@herbertland.com>
	<1463434389-314297-10-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:36537 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbcEPWZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 18:25:07 -0400
Received: by mail-io0-f173.google.com with SMTP id i75so1169101ioa.3
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 15:25:06 -0700 (PDT)
In-Reply-To: <1463434389-314297-10-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2016 at 2:33 PM, Tom Herbert <tom@herbertland.com> wrote:
> Add encap_hlen and ip_tunnel_encap structure to ip6_tnl. Add functions
> for getting encap hlen, setting up encap on a tunnel, performing
> encapsulation operation.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/net/ip6_tunnel.h  | 58 ++++++++++++++++++++++++++++++++
>  net/ipv4/ip_tunnel_core.c |  5 +++
>  net/ipv6/ip6_tunnel.c     | 85 ++++++++++++++++++++++++++++++++++++++++++-----
>  3 files changed, 139 insertions(+), 9 deletions(-)
>

So it looks like you completely dropped the two spots that were
updating mtu and max_headroom with the t->hlen.  I thought you needed
to at least have a check that used t->encap_hlen here in order to
avoid overflowing the buffer or exceeding skb_headroom, or am I
missing something?

- Alex
