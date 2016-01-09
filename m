From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH net-next 2/4] bpf: bpf_htab: Add BPF_MAP_TYPE_PERCPU_HASH
Date: Sat, 9 Jan 2016 18:33:00 +0800
Message-ID: <CACVXFVO6UmTpN9QAAgspMgBcp-Oaz370uCyZDVLZzNboPaKMnQ@mail.gmail.com>
References: <1452206155-1492617-1-git-send-email-kafai@fb.com>
	<1452206155-1492617-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452206155-1492617-3-git-send-email-kafai@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 8, 2016 at 6:35 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> This patch adds BPFMAP_TYPE_PERCPU_HASH map type and its
> htab_map_ops implementation.
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---
>  include/uapi/linux/bpf.h |   1 +
>  kernel/bpf/hashtab.c     | 201 ++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 201 insertions(+), 1 deletion(-)
...
> +
> +/* Called from syscall or eBPF program */
> +static void *htab_percpu_map_lookup_elem(struct bpf_map *map, void *key)
> +{
> +       struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
> +       struct htab_elem_common *l;
> +
> +       l = __htab_map_lookup_elem(htab, key);
> +       if (l) {
> +               void *value = per_cpu_ptr(htab_percpu_elem(l)->value,
> +                                         smp_processor_id());

Then it isn't possible to retrieve the value of one key from all CPUs in eBPF
prog, and that is definitely not flexible because update/delete element can
be run from eBPF prog.

And that is not a thing if using real_key and cpu_id, isn't it?

Thanks,
