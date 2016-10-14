From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3] IB/ipoib: move back IB LL address into the hard header
Date: Fri, 14 Oct 2016 13:23:31 +0300
Message-ID: <CAJ3xEMi7DY7_3vM+553dC4w17W==CdUdtn5PdzzCCUxtj434dQ@mail.gmail.com>
References: <9fce9b87ecc4c5c4f03401359806f40b1dcd0eb3.1476374992.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Alex Vesker <valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9fce9b87ecc4c5c4f03401359806f40b1dcd0eb3.1476374992.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 13, 2016 at 7:26 PM, Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> After the commit 9207f9d45b0a ("net: preserve IP control block
> during GSO segmentation"), the GSO CB and the IPoIB CB conflict.

the commit --> commit (remove the word "the" to make the sentence a
bit more clear)

> That destroy the IPoIB address information cached there,
> causing a severe performance regression, as better described here:

> http://marc.info/?l=linux-kernel&m=146787279825501&w=2

I don't think that links into this archive last for long.. try to find
something better
best if you can provide quick wording telling what is broken (e.g HW LSO)

> This change moves the data cached by the IPoIB driver from the
> skb control lock into the IPoIB hard header, as done before

lock --> block ?

> the commit 936d7de3d736 ("IPoIB: Stop lying about hard_header_len

the commit --> commit

> and use skb->cb to stash LL addresses").
> In order to avoid GRO issue, on packet reception, the IPoIB driver
> stash into the skb a dummy pseudo header, so that the received
> packets have actually a hard header matching the declared length.
> To avoid changing the connected mode maximum mtu, the allocated
> head buffer size is increased by the pseudo header length.

> After this commit, IPoIB performances are back to pre-regression
> value.
>
> v2 -> v3: rebased
> v1 -> v2: avoid changing the max mtu, increasing the head buf size

> Fixes: 9207f9d45b0a ("net: preserve IP control block during GSO segmentation")
> Signed-off-by: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Paolo,

Is this fix backportable to any kernel since the breakage? AFAIR,
Roland mentioned
that a 2nd change introduced in 4.7-rc1 changed things a bit more such
that the fix
he had in his head didn't apply any more.

Dave, Doug

I am still travelling after netdev and would like to put an eye on the
patch and also see that @mellanox.com someone
provides a  tested-by ack. Considering the fact that the bug is soon
to (de-)celebrate it's 1st anniversary and as we're still not in rc1,
the patch has enough time to get into 4.9... can you let it be here
for another week or so?

Or
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
