From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH] xdp: separate struct xdp_prog as container for bpf_prog
Date: Tue, 20 Sep 2016 22:21:31 +0200
Message-ID: <57E19A4B.6030101@iogearbox.net>
References: <20160920195458.21735.21873.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, bblanco@plumgrid.com,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
        tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50739 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751729AbcITUVf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 16:21:35 -0400
In-Reply-To: <20160920195458.21735.21873.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2016 09:55 PM, Jesper Dangaard Brouer wrote:
> Currently the XDP program is simply a bpf_prog pointer.  While it
> is good for simplicity, it is limiting extendability for upcoming
> features.
>
> Introducing a new struct xdp_prog, that can carry information
> related to the XDP program.  Notice this approach does not affect
> performance (tested and benchmarked), because the extra dereference
> for the eBPF program only happens once per 64 packets in the poll
> function.
>
> The features that need this is:
>
> * Multi-port TX:
>    Need to know own port index and port lookup table.
>
> * XDP program per RX queue:
>    Need setup info about program type, global or specific, due to
>    replace semantics.
>
> * Capabilities negotiation:
>    Need to store information about features program want to use,
>    in-order to validate this.
>
> I do realize this new struct xdp_prog features cannot go into the
> kernel before one of the three users of the struct is also implemented.

Yep, so this whole wrapper structure which adds yet another mgmt layer
with ref'counting etc is kind of hard to judge whether it's into the
right direction w/o showing a user of this struct. Each BPF prog does
have struct bpf_prog_aux, where we store auxiliary data, so I'd recommend
to try extending this with some private data, which can be for XDP type
etc since we know it's an XDP prog anyway. Or is there a specific reason
that this is impossible to do, resp. limiting?
