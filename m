From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net PATCH 1/2] bpf: bpf_compute_data uses incorrect cb structure
Date: Fri, 27 Oct 2017 12:43:30 -0700
Message-ID: <20171027194328.xfzxgesclwijkjz2@ast-mbp>
References: <20171027163830.28498.82997.stgit@john-Precision-Tower-5810>
 <20171027164534.28498.39170.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com,
        daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:54140 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932421AbdJ0Tne (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 15:43:34 -0400
Received: by mail-pg0-f49.google.com with SMTP id s2so6011852pge.10
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 12:43:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171027164534.28498.39170.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 09:45:34AM -0700, John Fastabend wrote:
> SK_SKB program types use bpf_compute_data to store the end of the
> packet data. However, bpf_compute_data assumes the cb is stored in the
> qdisc layer format. But, for SK_SKB this is the wrong layer of the
> stack for this type.
> 
> It happens to work (sort of!) because in most cases nothing happens
> to be overwritten today. This is very fragile and error prone.
> Fortunately, we have another hole in tcp_skb_cb we can use so lets
> put the data_end value there.
> 
> Note, SK_SKB program types do not use data_meta, they are failed by
> sk_skb_is_valid_access().
> 
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
