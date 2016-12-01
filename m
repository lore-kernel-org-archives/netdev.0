From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v4 3/4] bpf: BPF for lightweight tunnel infrastructure
Date: Thu, 01 Dec 2016 13:08:44 +0100
Message-ID: <584012CC.4030004@iogearbox.net>
References: <cover.1480522144.git.tgraf@suug.ch> <950bbc4f82150683dd87e26dbd41412c26a38eba.1480522144.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        tom@herbertland.com, roopa@cumulusnetworks.com,
        hannes@stressinduktion.org
To: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34763 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751997AbcLAMIw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 07:08:52 -0500
In-Reply-To: <950bbc4f82150683dd87e26dbd41412c26a38eba.1480522144.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2016 05:10 PM, Thomas Graf wrote:
> Registers new BPF program types which correspond to the LWT hooks:
>    - BPF_PROG_TYPE_LWT_IN   => dst_input()
>    - BPF_PROG_TYPE_LWT_OUT  => dst_output()
>    - BPF_PROG_TYPE_LWT_XMIT => lwtunnel_xmit()
>
> The separate program types are required to differentiate between the
> capabilities each LWT hook allows:
>
>   * Programs attached to dst_input() or dst_output() are restricted and
>     may only read the data of an skb. This prevent modification and
>     possible invalidation of already validated packet headers on receive
>     and the construction of illegal headers while the IP headers are
>     still being assembled.
>
>   * Programs attached to lwtunnel_xmit() are allowed to modify packet
>     content as well as prepending an L2 header via a newly introduced
>     helper bpf_skb_change_head(). This is safe as lwtunnel_xmit() is
>     invoked after the IP header has been assembled completely.
[...]
>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

LGTMAFAICT, so:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

For the verifier change in may_access_direct_pkt_data(), would be
great if you could later on follow up with a selftest-suite case,
one where BPF_PROG_TYPE_LWT_IN/OUT prog tries to write and fails,
and one where BPF_PROG_TYPE_LWT_IN/OUT prog uses pkt data to pass
to helpers, for example, so that we can keep testing it when future
changes in that area are made. Thanks.
