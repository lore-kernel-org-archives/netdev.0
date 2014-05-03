From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] ip_tunnel: Set network header properly for IP_ECN_decapsulate()
Date: Sat, 3 May 2014 16:08:08 -0400
Message-ID: <CADVnQy=t==TxnO=+Zf7Y8S-DBmLH9nz+vPFdZJgpP69wVVxdOw@mail.gmail.com>
References: <CAL1qit8_M+D_GM9EPeUUBgPdpHNANXeZjGO1vJ6NOS9OUhEZMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Ying Cai <ycai@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:45918 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbaECUIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 16:08:09 -0400
Received: by mail-wg0-f44.google.com with SMTP id a1so3419816wgh.15
        for <netdev@vger.kernel.org>; Sat, 03 May 2014 13:08:08 -0700 (PDT)
In-Reply-To: <CAL1qit8_M+D_GM9EPeUUBgPdpHNANXeZjGO1vJ6NOS9OUhEZMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 3, 2014 at 3:22 PM, Ying Cai <ycai@google.com> wrote:
> In ip_tunnel_rcv(), set skb->network_header to inner IP header
> before IP_ECN_decapsulate().
>
> Without the fix, IP_ECN_decapsulate() takes outer IP header as
> inner IP header, possibly causing error messages or packet drops.
> ---

Fixes: 3d7b46cd20e3 ("ip_tunnel: push generic protocol handling to
ip_tunnel module.")
Reported-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>

Note that this skb_reset_network_header() call was in this spot when
the original feature for checking consistency of ECN bits through
tunnels was added in eccc1bb8d4b4 ("tunnel: drop packet if ECN present
with not-ECT"). It was only removed from this spot in 3d7b46cd20e3
("ip_tunnel: push generic protocol handling to ip_tunnel
module."). Ying's fix restores that call.

Thanks, Ying.

neal
