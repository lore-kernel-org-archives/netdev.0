From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 2/4] mlx4: xdp: Allow raising MTU up to one page
 minus eth and vlan hdrs
Date: Sat, 3 Dec 2016 19:19:58 -0800
Message-ID: <20161204031958.GD70461@kafai-mba.local>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
 <1480721013-1047541-3-git-send-email-kafai@fb.com>
 <ba7950ad-d469-5e98-6ed1-ded9f58dba6b@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:32930 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752006AbcLDDU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 22:20:27 -0500
Content-Disposition: inline
In-Reply-To: <ba7950ad-d469-5e98-6ed1-ded9f58dba6b@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 04:07:09PM -0800, Rick Jones wrote:
> On 12/02/2016 03:23 PM, Martin KaFai Lau wrote:
> >When XDP prog is attached, it is currently limiting
> >MTU to be FRAG_SZ0 - ETH_HLEN - (2 * VLAN_HLEN) which is 1514
> >in x86.
> >
> >AFAICT, since mlx4 is doing one page per packet for XDP,
> >we can at least raise the MTU limitation up to
> >PAGE_SIZE - ETH_HLEN - (2 * VLAN_HLEN) which this patch is
> >doing.  It will be useful in the next patch which allows
> >XDP program to extend the packet by adding new header(s).
>
> Is mlx4 the only driver doing page-per-packet?
Sorry for the late reply.  This allocation scheme is only effective
when XDP is active.  AFAIK, only mlx4/5 supports XDP now.
