From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Mon, 13 Mar 2017 16:44:19 -0700
Message-ID: <CANn89iKfsYgQmF1AM4zb1M6nnrAqEGJ+nmgJ_53T2NV812ZAVA@mail.gmail.com>
References: <20170313005848.7076-1-edumazet@google.com> <20170313173432.GA31333@ast-mbp.thefacebook.com>
 <CANn89iL_C8CMaxmkSvFxBMCjHx49JkEaKGoUPWMRYucrx09LnA@mail.gmail.com>
 <20170313183121.GA36306@ast-mbp.thefacebook.com> <CANn89iK1eyXH_6ViU0sj=yH+3+WVtVdXaAVBUkkcA=0dCvTkOA@mail.gmail.com>
 <20170313202300.GA52396@ast-mbp.thefacebook.com> <CANn89iK6+1KMuxv11TqvfNd2cWRPjWDNkFnO00uC15GMQfqs-g@mail.gmail.com>
 <20170313232137.GA77943@ast-mbp.thefacebook.com> <CANn89iL3ODh0xf=+P0gSYN-mGwACeeCO+OwtJzK5JEtOtMdPuw@mail.gmail.com>
 <20170313234050.GA82263@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35997 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751777AbdCMXoV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 19:44:21 -0400
Received: by mail-io0-f173.google.com with SMTP id l7so94479043ioe.3
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 16:44:20 -0700 (PDT)
In-Reply-To: <20170313234050.GA82263@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 4:40 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Mar 13, 2017 at 04:28:04PM -0700, Eric Dumazet wrote:
>> On Mon, Mar 13, 2017 at 4:21 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> >
>> > is it once in the beginning only? If so then why that
>> > 'if (!ring->page_cache.index)' check is done for every packet?
>>
>>
>>
>> You did not really read the patch, otherwise you would not ask these questions.
>
> please explain. I see
> +  if (!ring->page_cache.index) {
> +          npage = mlx4_alloc_page(priv, ring,
> which is done for every packet that goes via XDP_TX.
>

Well, we do for all packets, even on hosts not running XDP:

if (xdp_prog) { ...

...

Then :

if (doorbell_pending))
     mlx4_en_xmit_doorbell(priv->tx_ring[TX_XDP][cq->ring]);

And nobody complained of few additional instructions.

Should I had, very loudly ?


>> Test it, and if you find a regression, shout loudly.
>
> that's not how it works. It's a job of submitter to prove
> that additional code doesn't cause regressions especially
> when there are legitimate concerns.

I have no easy way to test XDP. I  have never used it and am not
planning to use it any time soon.

Does it mean I no longer can participate to linux dev ?

Nice to hear Alexei.
