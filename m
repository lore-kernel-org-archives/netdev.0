From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: don't forget to free sk_filter
Date: Wed, 06 Nov 2013 20:19:20 +0100
Message-ID: <527A9638.4020404@redhat.com>
References: <1383753106-26978-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	stable@vger.kernel.org.#.3.12
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383753106-26978-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/06/2013 04:51 PM, Andrey Vagin wrote:
> sk_filter isn't freed if bpf_func is equal to sk_run_filter.
>
> This memory leak was introduced by
> commit d45ed4a4e33ae103053c0a53d280014e7101bb5c
> Author: Alexei Starovoitov <ast@plumgrid.com>
> Date:   Fri Oct 4 00:14:06 2013 -0700
>
>      net: fix unsafe set_memory_rw from softirq
>
> Before this patch sk_filter was freed in sk_filter_release_rcu,
> now it is freed in bpf_jit_free.
>
> Here is output of kmemleak:
> unreferenced object 0xffff8800b774eab0 (size 128):
>    comm "systemd", pid 1, jiffies 4294669014 (age 124.062s)
>    hex dump (first 32 bytes):
>      00 00 00 00 0b 00 00 00 20 63 7f b7 00 88 ff ff  ........ c......
>      60 d4 55 81 ff ff ff ff 30 d9 55 81 ff ff ff ff  `.U.....0.U.....
>    backtrace:
>      [<ffffffff816444be>] kmemleak_alloc+0x4e/0xb0
>      [<ffffffff811845af>] __kmalloc+0xef/0x260
>      [<ffffffff81534028>] sock_kmalloc+0x38/0x60
>      [<ffffffff8155d4dd>] sk_attach_filter+0x5d/0x190
>      [<ffffffff815378a1>] sock_setsockopt+0x991/0x9e0
>      [<ffffffff81531bd6>] SyS_setsockopt+0xb6/0xd0
>      [<ffffffff8165f3e9>] system_call_fastpath+0x16/0x1b
>      [<ffffffffffffffff>] 0xffffffffffffffff
>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: stable@vger.kernel.org # 3.12

^^^^ vi Documentation/networking/netdev-FAQ.txt +155

> Signed-off-by: Andrey Vagin <avagin@openvz.org>

When you send v2 with Alexei's feedback, please also be more specific
in your subject like "net: x86: bpf: don't forget to free sk_filter"
or the like. Also it's enough to say 'This memory leak was introduced
by commit d45ed4a4e3 ("net: fix unsafe set_memory_rw from softirq")'
instead of copying the whole log. Anyways, for v2 with feedback included
then:

Acked-by: Daniel Borkmann <dborkman@redhat.com>
