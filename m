From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH 3/3] net: ipv6: Implement /proc/net/icmp6.
Date: Wed, 29 May 2013 11:31:04 +0900
Message-ID: <CAKD1Yr0YXy+xoE4rVRFmd6pQbE+biw+8008Nd_VbyaSMn8c9+w@mail.gmail.com>
References: <1369752315-11167-1-git-send-email-lorenzo@google.com> <1369752315-11167-3-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:37838 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab3E2CbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 22:31:25 -0400
Received: by mail-qc0-f171.google.com with SMTP id n1so4439665qcx.16
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 19:31:24 -0700 (PDT)
In-Reply-To: <1369752315-11167-3-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 28, 2013 at 11:45 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> +int __init pingv6_init(void)
> +{
> +       int ret;
> +       pingv6_ops.ipv6_recv_error = ipv6_recv_error;
> +       pingv6_ops.ip6_datagram_recv_ctl = ip6_datagram_recv_ctl;
> +       pingv6_ops.icmpv6_err_convert = icmpv6_err_convert;
> +       pingv6_ops.ipv6_icmp_error = ipv6_icmp_error;
> +       pingv6_ops.ipv6_chk_addr = ipv6_chk_addr;
> +#ifdef CONFIG_PROC_FS
> +       ret = register_pernet_subsys(&ping_v6_net_ops);
> +       if (ret)
> +               return ret;

Nit: if register_pernet_subsys fails (ENOMEM?) then we return failure
and stop the IPv6 module from loading, but the function pointers
inside pingv6_ops are never cleared.

I don't think this has any impact, because if this happens, the proto
isn't registered, so there's no way to create an IPv6 socket and call
these function pointers. Still, for completeness' sake I'll shortly
send out another patch 3/3 that checks the result of
register_pernet_subsys before updating the function pointers. The
other two patches in the set don't need to change.
