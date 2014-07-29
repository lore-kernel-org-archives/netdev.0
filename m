From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH 1/2 v2 net-next] netfilter: xt_bpf: add mising opaque
 struct sk_filter definition
Date: Tue, 29 Jul 2014 12:40:25 -0400
Message-ID: <CA+FuTSdA-85qfDCDJtqGXJc13mJ5Qe-JMtZ19vrrvy4a-qkwuQ@mail.gmail.com>
References: <1406650335-5916-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Kees Cook <keescook@chromium.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f173.google.com ([209.85.220.173]:48204 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbaG2QlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 12:41:01 -0400
Received: by mail-vc0-f173.google.com with SMTP id hy10so13983052vcb.18
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 09:41:00 -0700 (PDT)
In-Reply-To: <1406650335-5916-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2014 at 12:12 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> This structure is not exposed to userspace, so fix this by defining
> struct sk_filter; so we skip the casting in kernelspace. This is safe
> since userspace has no way to lurk with that internal pointer.
>
> Fixes: e6f30c7 ("netfilter: x_tables: add xt_bpf match")
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Acked-by: Willem de Bruijn <willemb@google.com>

> ---
> v2: address Willem's feedback, we still need uapi/linux/filter.h for
>     userspace iptables builds.
>
>  include/uapi/linux/netfilter/xt_bpf.h |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/include/uapi/linux/netfilter/xt_bpf.h b/include/uapi/linux/netfilter/xt_bpf.h
> index 5dda450..2ec9fbc 100644
> --- a/include/uapi/linux/netfilter/xt_bpf.h
> +++ b/include/uapi/linux/netfilter/xt_bpf.h
> @@ -6,6 +6,8 @@
>
>  #define XT_BPF_MAX_NUM_INSTR   64
>
> +struct sk_filter;
> +
>  struct xt_bpf_info {
>         __u16 bpf_program_num_elem;
>         struct sock_filter bpf_program[XT_BPF_MAX_NUM_INSTR];
> --
> 1.7.10.4
>
