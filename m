From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 2/6] bpf: Add percpu LRU list
Date: Mon, 14 Nov 2016 17:51:28 -0800
Message-ID: <20161115015126.GD8080@ast-mbp.thefacebook.com>
References: <1478890511-1346984-1-git-send-email-kafai@fb.com>
 <1478890511-1346984-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35266 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933258AbcKOBvc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 20:51:32 -0500
Received: by mail-pf0-f193.google.com with SMTP id i88so6976417pfk.2
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 17:51:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1478890511-1346984-3-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 11, 2016 at 10:55:07AM -0800, Martin KaFai Lau wrote:
> Instead of having a common LRU list, this patch allows a
> percpu LRU list which can be selected by specifying a map
> attribute.  The map attribute will be added in the later
> patch.
> 
> While the common use case for LRU is #reads >> #updates,
> percpu LRU list allows bpf prog to absorb unusual #updates
> under pathological case (e.g. external traffic facing machine which
> could be under attack).
> 
> Each percpu LRU is isolated from each other.  The LRU nodes (including
> free nodes) cannot be moved across different LRU Lists.
> 
> Here are the update performance comparison between
> common LRU list and percpu LRU list (the test code is
> at the last patch):
> 
> [root@kerneltest003.31.prn1 ~]# for i in 1 4 8; do echo -n "$i cpus: "; \
> ./map_perf_test 16 $i | awk '{r += $3}END{print r " updates"}'; done
>  1 cpus: 2934082 updates
>  4 cpus: 7391434 updates
>  8 cpus: 6500576 updates
> 
> [root@kerneltest003.31.prn1 ~]# for i in 1 4 8; do echo -n "$i cpus: "; \
> ./map_perf_test 32 $i | awk '{r += $3}END{printr " updates"}'; done
>   1 cpus: 2896553 updates
>   4 cpus: 9766395 updates
>   8 cpus: 17460553 updates
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
