From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] socket, bpf: fix possible use after free
Date: Mon, 02 Oct 2017 21:42:38 +0200
Message-ID: <59D296AE.3080102@iogearbox.net>
References: <1506972051.8061.30.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39259 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751102AbdJBTmo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 15:42:44 -0400
In-Reply-To: <1506972051.8061.30.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/2017 09:20 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Starting from linux-4.4, 3WHS no longer takes the listener lock.
>
> Since this time, we might hit a use-after-free in sk_filter_charge(),
> if the filter we got in the memcpy() of the listener content
> just happened to be replaced by a thread changing listener BPF filter.
>
> To fix this, we need to make sure the filter refcount is not already
> zero before incrementing it again.
>
> Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks, Eric!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
