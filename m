From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH]  tcp_cubic: fix the range of delayed_ack
Date: Wed, 30 Apr 2014 07:18:18 -0700
Message-ID: <1398867498.29914.151.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5360C391.2040202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, shemminger@vyatta.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Liu Yu <allanliuyu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:55040 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759041AbaD3O0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 10:26:15 -0400
Received: by mail-pd0-f172.google.com with SMTP id g10so1769688pdj.31
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 07:26:13 -0700 (PDT)
In-Reply-To: <5360C391.2040202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-30 at 17:34 +0800, Liu Yu wrote:
> From: Liu Yu <allanyuliu@tencent.com>
> 
> commit b9f47a3aaeab (tcp_cubic: limit delayed_ack ratio to prevent
> divide error) try to prevent divide error, but there is still a little
> chance that delayed_ack can reach zero. In case the param cnt get
> negative value, then ratio+cnt would overflow and may happen to be zero.
> As a result, min(ratio, ACK_RATIO_LIMIT) will calculate to be zero.
> 
> In some old kernels, such as 2.6.32, there is a bug that would
> pass negative param, which then ultimately leads to this divide error.
> 
> commit 5b35e1e6e9c (tcp: fix tcp_trim_head() to adjust segment count
> with skb MSS) fixed the negative param issue. However, 
> it's safe that we fix the range of delayed_ack as well,
> to make sure we do not hit a divide by zero.
> 
> CC: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Liu Yu <allanyuliu@tencent.com>
> ---
>  net/ipv4/tcp_cubic.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks !
