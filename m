From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] x86: bpf_jit: small optimization in
 emit_bpf_tail_call()
Date: Thu, 31 Aug 2017 07:38:20 -0700
Message-ID: <20170831143818.6s7lbu6ai7dqveah@ast-mbp.dhcp.thefacebook.com>
References: <1504180422.15310.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35035 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751011AbdHaOiU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 10:38:20 -0400
Received: by mail-pg0-f67.google.com with SMTP id r133so598080pgr.2
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 07:38:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1504180422.15310.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 04:53:42AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Saves 4 bytes replacing following instructions :
> 
> lea rax, [rsi + rdx * 8 + offsetof(...)] 
> mov rax, qword ptr [rax]
> cmp rax, 0
> 
> by :
> 
> mov rax, [rsi + rdx * 8 + offsetof(...)] 
> test rax, rax
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Nicely spotted. Much appreciate it!
Acked-by: Alexei Starovoitov <ast@kernel.org>
