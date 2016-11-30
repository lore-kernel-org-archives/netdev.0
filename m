From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v4 3/4] bpf: BPF for lightweight tunnel
 infrastructure
Date: Wed, 30 Nov 2016 15:43:54 -0800
Message-ID: <20161130234352.GA37423@ast-mbp.thefacebook.com>
References: <cover.1480522144.git.tgraf@suug.ch>
 <950bbc4f82150683dd87e26dbd41412c26a38eba.1480522144.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        tom@herbertland.com, roopa@cumulusnetworks.com,
        hannes@stressinduktion.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33932 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751150AbcK3XoD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 18:44:03 -0500
Received: by mail-pf0-f196.google.com with SMTP id y68so10795909pfb.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 15:44:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <950bbc4f82150683dd87e26dbd41412c26a38eba.1480522144.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 05:10:10PM +0100, Thomas Graf wrote:
> Registers new BPF program types which correspond to the LWT hooks:
>   - BPF_PROG_TYPE_LWT_IN   => dst_input()
>   - BPF_PROG_TYPE_LWT_OUT  => dst_output()
>   - BPF_PROG_TYPE_LWT_XMIT => lwtunnel_xmit()
> 
> The separate program types are required to differentiate between the
> capabilities each LWT hook allows:
> 
>  * Programs attached to dst_input() or dst_output() are restricted and
>    may only read the data of an skb. This prevent modification and
>    possible invalidation of already validated packet headers on receive
>    and the construction of illegal headers while the IP headers are
>    still being assembled.
> 
>  * Programs attached to lwtunnel_xmit() are allowed to modify packet
>    content as well as prepending an L2 header via a newly introduced
>    helper bpf_skb_change_head(). This is safe as lwtunnel_xmit() is
>    invoked after the IP header has been assembled completely.
> 
> All BPF programs receive an skb with L3 headers attached and may return
> one of the following error codes:
> 
>  BPF_OK - Continue routing as per nexthop
>  BPF_DROP - Drop skb and return EPERM
>  BPF_REDIRECT - Redirect skb to device as per redirect() helper.
>                 (Only valid in lwtunnel_xmit() context)
> 
> The return codes are binary compatible with their TC_ACT_
> relatives to ease compatibility.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Looks great.

Acked-by: Alexei Starovoitov <ast@kernel.org>
