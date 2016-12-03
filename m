From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 2/4] mlx4: xdp: Allow raising MTU up to one page
 minus eth and vlan hdrs
Date: Fri, 2 Dec 2016 16:53:09 -0800
Message-ID: <58421775.6090905@fb.com>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
 <1480721013-1047541-3-git-send-email-kafai@fb.com>
 <1480725480.18162.394.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>,
        "Daniel Borkmann" <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        "Saeed Mahameed" <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "Kernel Team" <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36228 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753063AbcLCAxm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 19:53:42 -0500
In-Reply-To: <1480725480.18162.394.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/2/16 4:38 PM, Eric Dumazet wrote:
> On Fri, 2016-12-02 at 15:23 -0800, Martin KaFai Lau wrote:
>> When XDP prog is attached, it is currently limiting
>> MTU to be FRAG_SZ0 - ETH_HLEN - (2 * VLAN_HLEN) which is 1514
>> in x86.
>>
>> AFAICT, since mlx4 is doing one page per packet for XDP,
>> we can at least raise the MTU limitation up to
>> PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN) which this patch is
>> doing.  It will be useful in the next patch which allows
>> XDP program to extend the packet by adding new header(s).
>>
>> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
>> ---
>
> Have you tested your patch on a host with PAGE_SIZE = 64 KB ?
>
> Looks XDP really kills arches with bigger pages :(

I'm afraid xdp mlx[45] support was not tested on arches
with 64k pages at all. Not just this patch.
I think people who care about such archs should test?
Note page per packet is not a hard requirement for all drivers
and all archs. For mlx[45] it was the easiest and the most
convenient way to achieve desired performance.
If there are ways to do the same performance differently,
I'm all ears :)
