From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: net/packet: use-after-free in packet_rcv_fanout
Date: Sun, 12 Feb 2017 20:42:39 -0500
Message-ID: <20170213014239.GA21934@oracle.com>
References: <CACT4Y+a2tTARdXKtjtWny9hAPc9b8Q-v8ya3TOV-T+8s=PR2HQ@mail.gmail.com>
 <CAM_iQpXDwx3=tF4Atu7O+STswdTxLFzzT5-K2bgqtcWcF4aghA@mail.gmail.com>
 <1486696765.7793.119.camel@edumazet-glaptop3.roam.corp.google.com>
 <1486697003.7793.121.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXHktH+Wo7GtJC4afY_Wm11PpKcNFx41f_x4Vs93J-bMA@mail.gmail.com>
 <1486749566.7793.150.camel@edumazet-glaptop3.roam.corp.google.com>
 <1486749763.7793.152.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Anoob Soman <anoob.soman@citrix.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, jarno@ovn.org,
        philip.pettersson@gmail.com, weongyo.linux@gmail.com,
        netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25963 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751593AbdBMBnP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 20:43:15 -0500
Content-Disposition: inline
In-Reply-To: <1486749763.7793.152.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (02/10/17 10:02), Eric Dumazet wrote:
> At least, Anoob patch is making a step into the right direction ;)
> https://patchwork.ozlabs.org/patch/726532/

I've not been able to reproduce Dmitry's panic (though I did not try
very hard either) but there's a call to fanout_release from packet_release
before the synchronize_net() - I wonder if this could end up kfree'ing f
when there are threads in the middle of dev_queue_xmit_nit().

--Sowmini
 
