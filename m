From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net: tcp: dctcp_update_alpha() fixes.
Date: Thu, 11 Jun 2015 23:07:32 +0200
Message-ID: <5579F894.3030104@iogearbox.net>
References: <1433999477.27504.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33486 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbbFKVHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 17:07:36 -0400
In-Reply-To: <1433999477.27504.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/2015 07:11 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> dctcp_alpha can be read by from dctcp_get_info() without
> synchro, so use WRITE_ONCE() to prevent compiler from using
> dctcp_alpha as a temporary variable.
>
> Also, playing with small dctcp_shift_g (like 1), can expose
> an overflow with 32bit values shifted 9 times before divide.
>
> Use an u64 field to avoid this problem, and perform the divide
> only if acked_bytes_ecn is not zero.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Change looks correct to me, thanks Eric!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
