From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] udp: fix linear skb reception with PEEK_OFF
Date: Mon, 14 Aug 2017 14:06:28 -0700
Message-ID: <1502744788.4936.30.camel@edumazet-glaptop3.roam.corp.google.com>
References: <18c1b112032a685518548760890547fdbf292b85.1502739025.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Sasha Levin <alexander.levin@verizon.com>,
        Al Viro <viro@ZenIV.linux.org.uk>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32903 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752286AbdHNVGb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 17:06:31 -0400
Received: by mail-pg0-f66.google.com with SMTP id u185so12408429pgb.0
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 14:06:31 -0700 (PDT)
In-Reply-To: <18c1b112032a685518548760890547fdbf292b85.1502739025.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-14 at 21:31 +0200, Paolo Abeni wrote:
> From: Al Viro <viro@ZenIV.linux.org.uk>
> 
> copy_linear_skb() is broken; both of its callers actually
> expect 'len' to be the amount we are trying to copy,
> not the offset of the end.
> Fix it keeping the meanings of arguments in sync with what the
> callers (both of them) expect.
> Also restore a saner behavior on EFAULT (i.e. preserving
> the iov_iter position in case of failure):
> 
> The commit fd851ba9caa9 ("udp: harden copy_linear_skb()")
> avoids the more destructive effect of the buggy
> copy_linear_skb(), e.g. no more invalid memory access, but
> said function still behaves incorrectly: when peeking with
> offset it can fail with EINVAL instead of copying the
> appropriate amount of memory.
> 
> Reported-by: Sasha Levin <alexander.levin@verizon.com>
> Fixes: b65ac44674dd ("udp: try to avoid 2 cache miss on dequeue")
> Fixes: fd851ba9caa9 ("udp: harden copy_linear_skb()")
> Signed-off-by: Al Viro <viro@ZenIV.linux.org.uk>
> Acked-by: Paolo Abeni <pabeni@redhat.com>
> Tested-by: Sasha Levin <alexander.levin@verizon.com>
> ---

Oh well.

Acked-by: Eric Dumazet <edumazet@google.com>
