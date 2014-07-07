From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] appletalk: Set skb with destructor
Date: Mon, 07 Jul 2014 11:26:57 +0200
Message-ID: <1404725217.4501.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140705202821.GA25880@mwanda>
	 <1404647816-7564-1-git-send-email-andrey.krieger.utkin@gmail.com>
	 <1404682932.4501.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CANZNk81v7YHKpzjZ65KHdUi1BgBiV_ibZO24b8uauuCVZeUv2A@mail.gmail.com>
	 <1404723456.4501.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	acme@ghostprotocols.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404723456.4501.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-07-07 at 10:57 +0200, Eric Dumazet wrote:
> On Mon, 2014-07-07 at 11:03 +0300, Andrey Utkin wrote:
> > 2014-07-07 0:42 GMT+03:00 Eric Dumazet <eric.dumazet@gmail.com>:
> > >>       /* Queue packet (standard) */
> > >> +     sock_hold(sock);
> > >> +     skb->destructor = atalk_skb_destructor;
> > >>       skb->sk = sock;
> > >
> > > This part is not needed : sock_queue_rcv_skb() already does the right
> > > thing : It calls skb_set_owner_r(skb, sk);
> > >
> > > You should therefore remove the "skb->sk = sock;" line
> > 
> > If it is so, i think this should be as another patch with its own reasoning.
> > 
> 
> No it is not.
> 
> Its illegal to set skb->sk to a socket without taking proper reference.
> 
> But it is useless to do this before calling sock_queue_rcv_skb(), as I
> explained to you.
> 
> This is adding two extra atomic operations for nothing: skb_orphan() is
> called from sock_queue_rcv_skb(), so it is kind of stupid to set a
> destructor that _will_ be immediately called.
> 
> We do not do defensive programming, we try to do logical things, and
> only logical things.
> 
> Please re-spin your patch, by integrating my feedback.
> 
> Thanks !

Reading again this code, I think all you need is to remove the 2 buggy
lines.

No need for setup destructors.
