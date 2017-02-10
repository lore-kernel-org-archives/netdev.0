From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/packet: use-after-free in packet_rcv_fanout
Date: Fri, 10 Feb 2017 10:02:43 -0800
Message-ID: <1486749763.7793.152.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+a2tTARdXKtjtWny9hAPc9b8Q-v8ya3TOV-T+8s=PR2HQ@mail.gmail.com>
         <CAM_iQpXDwx3=tF4Atu7O+STswdTxLFzzT5-K2bgqtcWcF4aghA@mail.gmail.com>
         <1486696765.7793.119.camel@edumazet-glaptop3.roam.corp.google.com>
         <1486697003.7793.121.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpXHktH+Wo7GtJC4afY_Wm11PpKcNFx41f_x4Vs93J-bMA@mail.gmail.com>
         <1486749566.7793.150.camel@edumazet-glaptop3.roam.corp.google.com>
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
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Anoob Soman <anoob.soman@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486749566.7793.150.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-02-10 at 09:59 -0800, Eric Dumazet wrote:
> On Fri, 2017-02-10 at 09:49 -0800, Cong Wang wrote:
> > On Thu, Feb 9, 2017 at 7:23 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > On Thu, 2017-02-09 at 19:19 -0800, Eric Dumazet wrote:
> > >
> > >> More likely the bug is in fanout_add(), with a buggy sequence in error
> > >> case, and not correct locking.
> > >>
> > >> kfree(po->rollover);
> > >> po->rollover = NULL;
> > >>
> > >> Two cpus entering fanout_add() (using the same af_packet socket,
> > >> syzkaller courtesy...) might both see po->fanout being NULL.
> > >>
> > >> Then they grab the mutex.  Too late...
> > >
> > > Patch could be :
> > >
> > 
> > For me, clearly the data structure that use-after-free'd is struct sock
> > rather than struct packet_rollover.
> 
> Fine. But your patch makes absolutely no sense.

At least, Anoob patch is making a step into the right direction ;)

https://patchwork.ozlabs.org/patch/726532/
