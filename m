From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: net/packet: use-after-free in packet_rcv_fanout
Date: Fri, 10 Feb 2017 11:16:24 -0800
Message-ID: <20170210191624.GA11187@oracle.com>
References: <CACT4Y+a2tTARdXKtjtWny9hAPc9b8Q-v8ya3TOV-T+8s=PR2HQ@mail.gmail.com>
 <CAM_iQpXDwx3=tF4Atu7O+STswdTxLFzzT5-K2bgqtcWcF4aghA@mail.gmail.com>
 <1486696765.7793.119.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170210033306.GA770@oracle.com>
 <CAM_iQpWtFo80Z5yDn1Mf6bcZg+OWCyeq98WF7t+bwxGOuSjXpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>, jarno@ovn.org,
        Philip Pettersson <philip.pettersson@gmail.com>,
        weongyo.linux@gmail.com, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAM_iQpWtFo80Z5yDn1Mf6bcZg+OWCyeq98WF7t+bwxGOuSjXpA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (02/10/17 10:00), Cong Wang wrote:
> My understanding about the race here is packet_release() doesn't
> wait for flying packets correctly, which leads to a flying packet still
> refers to the struct sock which is being released.
> 
> This could happen because struct packet_fanout is refcn'ted, it is
   :
> At least I believe this explains the crash Dmitry reported.

hmm, the proof of the pudding is in the eating- would be good to 
be able to reliably reproduce this somewhere (thus proving that
root-cause analysis is rock-solid), maybe by introducing artificial
delays to slow down paths..

I'm travelling at the moment but may be able to give this (try
to reproduce it reliably) next week.

--Sowmini
