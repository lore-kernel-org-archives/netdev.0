From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/4] mlx4: xdp: Allow raising MTU up to one
 page minus eth and vlan hdrs
Date: Fri, 02 Dec 2016 16:38:00 -0800
Message-ID: <1480725480.18162.394.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
         <1480721013-1047541-3-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36051 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753080AbcLCAjD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 19:39:03 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so9313891pgx.3
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 16:39:02 -0800 (PST)
In-Reply-To: <1480721013-1047541-3-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-02 at 15:23 -0800, Martin KaFai Lau wrote:
> When XDP prog is attached, it is currently limiting
> MTU to be FRAG_SZ0 - ETH_HLEN - (2 * VLAN_HLEN) which is 1514
> in x86.
> 
> AFAICT, since mlx4 is doing one page per packet for XDP,
> we can at least raise the MTU limitation up to
> PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN) which this patch is
> doing.  It will be useful in the next patch which allows
> XDP program to extend the packet by adding new header(s).
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---

Have you tested your patch on a host with PAGE_SIZE = 64 KB ?

Looks XDP really kills arches with bigger pages :(

Thanks.
