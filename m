From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net 3/3] tcp: fix xmit timer to only be reset if data ACKed/SACKed
Date: Tue, 1 Aug 2017 10:24:30 -0400
Message-ID: <CADVnQy=x1tAmaHEGbshKiyJWQufgX=uaQXif_r7aiLm3j8y4SA@mail.gmail.com>
References: <20170801025814.31206-1-ncardwell@google.com> <20170801025814.31206-4-ncardwell@google.com>
 <F95AC9340317A84688A5F0DF0246F3F202933A7F@DGGEMI512-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>
To: maowenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:36358 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751295AbdHAOZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 10:25:02 -0400
Received: by mail-oi0-f48.google.com with SMTP id g131so16469717oic.3
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 07:25:02 -0700 (PDT)
In-Reply-To: <F95AC9340317A84688A5F0DF0246F3F202933A7F@DGGEMI512-MBX.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 1, 2017 at 8:20 AM, maowenan <maowenan@huawei.com> wrote:
> > +     /* If needed, reset TLP/RTO timer; RACK may later override this. */
> [Mao Wenan] I have question about RACK, if there is no RACK feature
> in lower version, who can clear this flag:FLAG_SET_XMIT_TIMER?

In the comment, "this" is referring to the xmit timer. The comment is
referring to the fact that RACK (or similarly
tcp_pause_early_retransmit() in earlier kernels) can override the
value of the xmit timer set in tcp_set_xmit_timer(). The comment is
not claiming that RACK clears the FLAG_SET_XMIT_TIMER bit in "flag".

Note that "flag" is an argument to tcp_ack(). And while processing a
given incoming ACK, the callers of tcp_ack() pass in either 0 or one
or more constant bit flags. So FLAG_SET_XMIT_TIMER and all the other
bit flags are implicitly set to zero at the beginning of processing
each ACK.

neal
