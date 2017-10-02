From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] socket, bpf: fix possible use after free
Date: Mon, 2 Oct 2017 12:35:08 -0700
Message-ID: <20171002193506.lx6sfr3hejdzarsl@ast-mbp.dhcp.thefacebook.com>
References: <1506972051.8061.30.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37474 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdJBTfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 15:35:12 -0400
Received: by mail-pg0-f67.google.com with SMTP id o1so5782099pga.4
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 12:35:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1506972051.8061.30.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 02, 2017 at 12:20:51PM -0700, Eric Dumazet wrote:
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

Thanks for the fix!
Acked-by: Alexei Starovoitov <ast@kernel.org>
