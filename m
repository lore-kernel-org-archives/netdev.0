From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: fix possible uninitialized access in inactive rotation
Date: Wed, 16 Nov 2016 17:00:10 +0100
Message-ID: <582C828A.60605@iogearbox.net>
References: <20161116143836.2448688-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161116143836.2448688-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/16/2016 03:38 PM, Arnd Bergmann wrote:
> This newly added code causes a build warning:
>
> kernel/bpf/bpf_lru_list.c: In function '__bpf_lru_list_rotate_inactive':
> kernel/bpf/bpf_lru_list.c:201:28: error: 'next' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>
> The warning is plausible from looking at the code, though there might
> be non-obvious external constraints that ensure it always works.
>
> Moving the assignment of ->next_inactive_rotation inside of the
> loop makes it obvious to the reader and the compiler when we
> actually want to update ->next.
>
> Fixes: 3a08c2fd7634 ("bpf: LRU List")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks a lot, Arnd, patch was already sent here though:

http://patchwork.ozlabs.org/patch/695202/
