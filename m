From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/4] mlx4: xdp: Allow raising MTU up to one
 page minus eth and vlan hdrs
Date: Fri, 02 Dec 2016 18:15:26 -0800
Message-ID: <1480731326.18162.397.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
         <1480721013-1047541-3-git-send-email-kafai@fb.com>
         <1480725480.18162.394.camel@edumazet-glaptop3.roam.corp.google.com>
         <58421775.6090905@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35271 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933080AbcLCCP3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 21:15:29 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so9494497pga.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 18:15:28 -0800 (PST)
In-Reply-To: <58421775.6090905@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-12-02 at 16:53 -0800, Alexei Starovoitov wrote:
> On 12/2/16 4:38 PM, Eric Dumazet wrote:
> > On Fri, 2016-12-02 at 15:23 -0800, Martin KaFai Lau wrote:
> >> When XDP prog is attached, it is currently limiting
> >> MTU to be FRAG_SZ0 - ETH_HLEN - (2 * VLAN_HLEN) which is 1514
> >> in x86.
> >>
> >> AFAICT, since mlx4 is doing one page per packet for XDP,
> >> we can at least raise the MTU limitation up to
> >> PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN) which this patch is
> >> doing.  It will be useful in the next patch which allows
> >> XDP program to extend the packet by adding new header(s).
> >>
> >> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> >> ---
> >
> > Have you tested your patch on a host with PAGE_SIZE = 64 KB ?
> >
> > Looks XDP really kills arches with bigger pages :(
> 
> I'm afraid xdp mlx[45] support was not tested on arches
> with 64k pages at all. Not just this patch.
> I think people who care about such archs should test?
> Note page per packet is not a hard requirement for all drivers
> and all archs. For mlx[45] it was the easiest and the most
> convenient way to achieve desired performance.
> If there are ways to do the same performance differently,
> I'm all ears :)
> 

My question was more like :

Can we double check all these patches wont break mlx4 driver (non XDP
path) on arches with PAGE_SIZE=64KB.

I have no plan using XDP before a while, but I certainly know some
customers are using mlx4 on powerpc.
