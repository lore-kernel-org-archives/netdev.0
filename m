From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5] tcp: plug dst leak in tcp_v6_conn_request()
Date: Sun, 24 Jun 2012 08:44:12 +0200
Message-ID: <1340520252.23933.0.camel@edumazet-glaptop>
References: <1340515324-2152-1-git-send-email-ncardwell@google.com>
	 <1340515324-2152-5-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:40719 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888Ab2FXGoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 02:44:16 -0400
Received: by wgbdr13 with SMTP id dr13so3058873wgb.1
        for <netdev@vger.kernel.org>; Sat, 23 Jun 2012 23:44:14 -0700 (PDT)
In-Reply-To: <1340515324-2152-5-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-06-24 at 01:22 -0400, Neal Cardwell wrote:
> The code in tcp_v6_conn_request() was implicitly assuming that
> tcp_v6_send_synack() would take care of dst_release(), much as
> tcp_v4_send_synack() already does. This resulted in
> tcp_v6_conn_request() leaking a dst if sysctl_tw_recycle is enabled.
> 
> This commit restructures tcp_v6_send_synack() so that it accepts a dst
> pointer and takes care of releasing the dst that is passed in, to plug
> the leak and avoid future surprises by bringing the IPv6 behavior in
> line with the IPv4 side.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---

Neal, your patches are for net-next, right ?
