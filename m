From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 1/2] netfilter: xt_bpf: don't include
 linux/filter.h from uapi header
Date: Tue, 29 Jul 2014 11:43:57 -0400
Message-ID: <CA+FuTSdRmnFYK1mTFh14UP1rTkU-EYK-61xyoWWiNvZR3Aig6A@mail.gmail.com>
References: <1406648188-3681-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>, keescook@chromium.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1406648188-3681-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> In e6f30c7 ("netfilter: x_tables: add xt_bpf match"), the internal
> linux/filter.h header slipped through in the user exposed xt_bpf.h
> header as included file.

is that true? #include <linux/filter.h> should include
include/uapi/linux/filter.h in userspace builds.

>
> +struct sk_filter;
> +
>  struct xt_bpf_info {
>         __u16 bpf_program_num_elem;
>         struct sock_filter bpf_program[XT_BPF_MAX_NUM_INSTR];

I think include/uapi/linux/filter.h is still needed for the definition
of struct sock_filter.

The uapi file does not declare sk_filter, so we do need to add the
forward declaration. Thanks, Pablo.
