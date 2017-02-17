From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/packet: use-after-free in packet_rcv_fanout
Date: Fri, 17 Feb 2017 11:27:15 -0800
Message-ID: <CAM_iQpUDhakMjof97qWvyLFXiDMiL6FUv+5OzGTPbnCXZp=Pzw@mail.gmail.com>
References: <CACT4Y+a2tTARdXKtjtWny9hAPc9b8Q-v8ya3TOV-T+8s=PR2HQ@mail.gmail.com>
 <CAM_iQpXDwx3=tF4Atu7O+STswdTxLFzzT5-K2bgqtcWcF4aghA@mail.gmail.com>
 <1486696765.7793.119.camel@edumazet-glaptop3.roam.corp.google.com>
 <1486697003.7793.121.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXHktH+Wo7GtJC4afY_Wm11PpKcNFx41f_x4Vs93J-bMA@mail.gmail.com>
 <1486749566.7793.150.camel@edumazet-glaptop3.roam.corp.google.com>
 <1486749763.7793.152.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170213014239.GA21934@oracle.com> <CACT4Y+bdZRYC5EyifuqBQWNNZ-sHBDXyVBvnzPCq8eg4-SHJ9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Anoob Soman <anoob.soman@citrix.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, jarno@ovn.org,
        Philip Pettersson <philip.pettersson@gmail.com>,
        weongyo.linux@gmail.com, netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:35719 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755550AbdBQT1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 14:27:37 -0500
Received: by mail-wr0-f170.google.com with SMTP id c4so35353486wrd.2
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 11:27:36 -0800 (PST)
In-Reply-To: <CACT4Y+bdZRYC5EyifuqBQWNNZ-sHBDXyVBvnzPCq8eg4-SHJ9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2017 at 7:17 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>
> Another similar one:
>

The other possibility is:  __fanout_link() is called twice on the same
packet sock
for some reason, but __fanout_unlink() only unlinks the first one, which led to
this use-after-free. However, the po->running and po->fanout seem enough
to guarantee this should not happen. I still want to point this out in case I
miss anything here so that other people could figure it out.
