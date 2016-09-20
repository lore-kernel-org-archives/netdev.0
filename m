From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 01:09:27 +0200
Message-ID: <20160920230927.GG3291@pox.localdomain>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
 <20160920224416.GF3291@pox.localdomain>
 <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36823 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753805AbcITXJa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 19:09:30 -0400
Received: by mail-wm0-f48.google.com with SMTP id w84so161139870wmg.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 16:09:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/16 at 03:49pm, Tom Herbert wrote:
> On Tue, Sep 20, 2016 at 3:44 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > On 09/20/16 at 03:00pm, Tom Herbert wrote:
> >> +static inline int __xdp_hook_run(struct list_head *list_head,
> >> +                              struct xdp_buff *xdp)
> >> +{
> >> +     struct xdp_hook_ops *elem;
> >> +     int ret = XDP_PASS;
> >> +
> >> +     list_for_each_entry(elem, list_head, list) {
> >> +             ret = elem->hook(elem->priv, xdp);
> >> +             if (ret != XDP_PASS)
> >> +                     break;
> >> +     }
> >
> > Walking over a linear list? Really? :-) I thought this was supposed
> > to be fast, no compromises made.
> 
> Can you suggest an alternative?

Single BPF program that encodes whatever logic is required. This is
what BPF is for. If it absolutely has to run two programs in sequence
then it can still do that even though I really don't see much of a
point of doing that in a high performance environment.

I'm not even sure yet I understand full purpose of this yet ;-)
