From: David Ahern <dsahern@gmail.com>
Subject: Re: [net-next PATCH 2/2] bpf: sock_map fixes for !CONFIG_BPF_SYSCALL
 and !STREAM_PARSER
Date: Wed, 16 Aug 2017 16:06:47 -0600
Message-ID: <1b280444-18dc-7207-1708-f651a1cf2a52@gmail.com>
References: <20170816220049.25438.62373.stgit@john-Precision-Tower-5810>
 <20170816220232.25438.47447.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>, daniel@iogearbox.net,
        davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35747 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752233AbdHPWGt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 18:06:49 -0400
Received: by mail-pg0-f65.google.com with SMTP id t80so442460pgb.2
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 15:06:49 -0700 (PDT)
In-Reply-To: <20170816220232.25438.47447.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/16/17 4:02 PM, John Fastabend wrote:
> diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
> index aa24287..897daa0 100644
> --- a/kernel/bpf/Makefile
> +++ b/kernel/bpf/Makefile
> @@ -3,7 +3,10 @@ obj-y := core.o
>  obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o tnum.o
>  obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o bpf_lru_list.o lpm_trie.o map_in_map.o
>  ifeq ($(CONFIG_NET),y)
> -obj-$(CONFIG_BPF_SYSCALL) += devmap.o sockmap.o
> +obj-$(CONFIG_BPF_SYSCALL) += devmap.o
> +ifeq ($(CONFIG_STREAM_PARSER),y)
> +obj-$(CONFIG_BPF_SYSCALL) += sockmap.o
> +endif
>  endif

sockmap requires KCM? I thought it just needed STREAM_PARSER. Can't
STREAM_PARSER be used outside of KCM? If so why not make STREAM_PARSER
enabled if sockmap is wanted vs requiring KCM to be compiled in to get
stream parser to get sockmap?
