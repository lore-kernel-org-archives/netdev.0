From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 2/2] bpf: fix unlocking of jited image when
 module ronx not set
Date: Tue, 21 Feb 2017 11:32:38 -0500
Message-ID: <CAF=yD-LQxhhMd0-cZVoC_jQiPVf+TU1hakFwgB2E=ndS+HBmwg@mail.gmail.com>
References: <cover.1487688093.git.daniel@iogearbox.net> <578a70ffeddfb08608dff0d223bfa51ab3b5ac93.1487688093.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>, labbott@redhat.com,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36925 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753745AbdBUQdZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 11:33:25 -0500
Received: by mail-wm0-f47.google.com with SMTP id v77so80168063wmv.0
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 08:33:19 -0800 (PST)
In-Reply-To: <578a70ffeddfb08608dff0d223bfa51ab3b5ac93.1487688093.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 10:09 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Eric and Willem reported that they recently saw random crashes when
> JIT was in use and bisected this to 74451e66d516 ("bpf: make jited
> programs visible in traces"). Issue was that the consolidation part
> added bpf_jit_binary_unlock_ro() that would unlock previously made
> read-only memory back to read-write. However, DEBUG_SET_MODULE_RONX
> cannot be used for this to test for presence of set_memory_*()
> functions. We need to use ARCH_HAS_SET_MEMORY instead to fix this;
> also add the corresponding bpf_jit_binary_lock_ro() to filter.h.
>
> Fixes: 74451e66d516 ("bpf: make jited programs visible in traces")
> Reported-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Willem de Bruijn <willemb@google.com>
> Bisected-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

This fixes the issue I observed. Thanks, Daniel.

Tested-by: Willem de Bruijn <willemb@google.com>
