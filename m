From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] sparc: bpf_jit: fix loads from negative offsets
Date: Wed, 24 Sep 2014 23:30:32 -0700
Message-ID: <CAMEtUuz1oxsFjQF6aJpcYEEAte=7-yoKorC+4ybZHyWxcHsUAg@mail.gmail.com>
References: <1411505410-25215-1-git-send-email-ast@plumgrid.com>
	<20140924.150837.1990547182303548810.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43284 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbaIYGad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 02:30:33 -0400
Received: by mail-we0-f174.google.com with SMTP id w62so6855088wes.5
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 23:30:32 -0700 (PDT)
In-Reply-To: <20140924.150837.1990547182303548810.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 12:08 PM, David Miller <davem@davemloft.net> wrote:
>
> BTW, there is a trick to load arbitrary negative 32-bit constants sign
> extended to 64-bit, in just two instructions:
>
>         sethi   %(~value), reg
>         xor     reg, ~(0x400 | (value & 0x3ff)), reg
>
> Or something like that, it's been a while.  GCC knows how to emit
> that sequence too.

nice, that's a neat trick.
gcc computes it as:
  sethi   %(~value), reg
  xor     reg, -0x400 | (value & 0x3ff), reg

and llvm as:
  sethi   %(~value), reg
  xor     reg, ~(~value & 0x3ff), reg

both are equivalent. I'll try to teach JIT to emit this.

Thanks!
