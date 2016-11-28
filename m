From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: samples: Fix compile of test_lru_dist.c
Date: Mon, 28 Nov 2016 10:17:23 +0100
Message-ID: <583BF623.7030103@iogearbox.net>
References: <1480307539-30187-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Martin KaFai Lau <kafai@fb.com>, ast@fb.com
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33821 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932094AbcK1JR0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 04:17:26 -0500
In-Reply-To: <1480307539-30187-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 05:32 AM, David Ahern wrote:
> Build of samples/bpf on debian/jessie fails with:
>
>    HOSTCC  /home/dsa/kernel-3.git/samples/bpf/test_lru_dist.o
> /home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c: In function ‘main’:
> /home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: error: variable ‘r’ has initializer but incomplete type
>    struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
>           ^
> /home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:21: error: ‘RLIM_INFINITY’ undeclared (first use in this function)
>    struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
>                       ^
> /home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:21: note: each undeclared identifier is reported only once for each function it appears in
> /home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: warning: excess elements in struct initializer
>    struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
>           ^
> /home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: warning: (near initialization for ‘r’)
> /home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: warning: excess elements in struct initializer
> /home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:9: warning: (near initialization for ‘r’)
> /home/dsa/kernel-3.git/samples/bpf/test_lru_dist.c:490:16: error: storage size of ‘r’ isn’t known
>    struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
>
> Add sys/resource.h to the include list
>
> Fixes: 5db58faf989f ("bpf: Add tests for the LRU bpf_htab")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> Cc: Martin KaFai Lau <kafai@fb.com>

Ran into the same issue, fixed here already:

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=e00c7b216f34444252f3771f7d4ed48d4f032636
