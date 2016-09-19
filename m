From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v6] gso: Support partial splitting at the
 frag_list pointer
Date: Mon, 19 Sep 2016 08:12:15 -0700
Message-ID: <CAKgT0UchF4mJNcsRNQ80j3wJ4LNQTA4WrNNgOTJ4m2k1_WjYfA@mail.gmail.com>
References: <20160919105847.GG31137@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33890 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750866AbcISPMQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 11:12:16 -0400
Received: by mail-io0-f176.google.com with SMTP id q92so94354704ioi.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 08:12:16 -0700 (PDT)
In-Reply-To: <20160919105847.GG31137@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 3:58 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> Since commit 8a29111c7 ("net: gro: allow to build full sized skb")
> gro may build buffers with a frag_list. This can hurt forwarding
> because most NICs can't offload such packets, they need to be
> segmented in software. This patch splits buffers with a frag_list
> at the frag_list pointer into buffers that can be TSO offloaded.
>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>
> Changes since v1:
>
> - Use the assumption that all buffers in the chain excluding the last
>   containing the same amount of data.
>
> - Simplify some checks against gso partial.
>
> - Fix the generation of IP IDs.
>
> Changes since v2:
>
> - Merge common code of gso partial and frag_list pointer splitting.
>
> Changes since v3:
>
> - Fix the checks for doing frag_list pointer splitting.
>
> Changes since v4:
>
> - Whitespace fix.
> - Fix size calculations of the tail packet.
>
> Changes since v5:
>
> - Fix another size calculations of the tail packet.
>
>
>  net/core/skbuff.c      | 51 +++++++++++++++++++++++++++++++++++++++-----------
>  net/ipv4/af_inet.c     | 14 ++++++++++----
>  net/ipv4/gre_offload.c |  6 ++++--
>  net/ipv4/tcp_offload.c | 13 +++++++------
>  net/ipv4/udp_offload.c |  6 ++++--
>  net/ipv6/ip6_offload.c |  5 ++++-
>  6 files changed, 69 insertions(+), 26 deletions(-)

Looks good.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
