From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/packet: use-after-free in packet_rcv_fanout
Date: Fri, 10 Feb 2017 09:59:26 -0800
Message-ID: <1486749566.7793.150.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+a2tTARdXKtjtWny9hAPc9b8Q-v8ya3TOV-T+8s=PR2HQ@mail.gmail.com>
         <CAM_iQpXDwx3=tF4Atu7O+STswdTxLFzzT5-K2bgqtcWcF4aghA@mail.gmail.com>
         <1486696765.7793.119.camel@edumazet-glaptop3.roam.corp.google.com>
         <1486697003.7793.121.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXHktH+Wo7GtJC4afY_Wm11PpKcNFx41f_x4Vs93J-bMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, jarno@ovn.org,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        philip.pettersson@gmail.com, weongyo.linux@gmail.com,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34533 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750903AbdBJSBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:01:02 -0500
In-Reply-To: <CAM_iQpXHktH+Wo7GtJC4afY_Wm11PpKcNFx41f_x4Vs93J-bMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-10 at 09:49 -0800, Cong Wang wrote:
> On Thu, Feb 9, 2017 at 7:23 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2017-02-09 at 19:19 -0800, Eric Dumazet wrote:
> >
> >> More likely the bug is in fanout_add(), with a buggy sequence in error
> >> case, and not correct locking.
> >>
> >> kfree(po->rollover);
> >> po->rollover = NULL;
> >>
> >> Two cpus entering fanout_add() (using the same af_packet socket,
> >> syzkaller courtesy...) might both see po->fanout being NULL.
> >>
> >> Then they grab the mutex.  Too late...
> >
> > Patch could be :
> >
> 
> For me, clearly the data structure that use-after-free'd is struct sock
> rather than struct packet_rollover.

Fine. But your patch makes absolutely no sense.
