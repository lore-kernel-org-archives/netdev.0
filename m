From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] Add uid and cookie bpf helper to
 cg_skb_func_proto
Date: Fri, 14 Apr 2017 17:07:53 -0700
Message-ID: <20170415000752.GC68140@ast-mbp.thefacebook.com>
References: <1492211534-6363-1-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34265 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755490AbdDOAH5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 20:07:57 -0400
Received: by mail-pg0-f66.google.com with SMTP id o123so18251843pga.1
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 17:07:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492211534-6363-1-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 14, 2017 at 04:12:14PM -0700, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> BPF helper functions get_socket_cookie and get_socket_uid can be
> used for network traffic classifications, among others. Expose
> them also to programs of type BPF_PROG_TYPE_CGROUP_SKB. As of
> commit 8f917bba0042 ("bpf: pass sk to helper functions") the required
> skb->sk function is available at both cgroup bpf ingress and egress
> hooks.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>

Thanks for follow up.
Another alternative is to do
cg_skb_func_proto(enum bpf_func_id func_id)
{
    return sk_filter_func_proto(func_id);
}

I think all socket filter helpers are applicable to cg_skb too.
