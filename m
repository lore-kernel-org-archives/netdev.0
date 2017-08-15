From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: fix linear skb reception with PEEK_OFF
Date: Mon, 14 Aug 2017 22:27:31 -0700 (PDT)
Message-ID: <20170814.222731.1125596980988732676.davem@davemloft.net>
References: <18c1b112032a685518548760890547fdbf292b85.1502739025.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        alexander.levin@verizon.com, viro@ZenIV.linux.org.uk
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751652AbdHOF1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 01:27:32 -0400
In-Reply-To: <18c1b112032a685518548760890547fdbf292b85.1502739025.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Mon, 14 Aug 2017 21:31:38 +0200

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
> This patch has been buried in a private email exchange for some
> time.
> I'm posting it on behalf of Al Viro, to avoid loosing this merge
> window, since he is busy elsewhere.

Applied, thanks.
