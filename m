From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: in-driver QoS
Date: Wed, 9 Jun 2004 21:27:28 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406092127.28477.vkondra@mail.ru>
References: <20040608184831.GA18462@bougret.hpl.hp.com> <200406090851.40691.vkondra@mail.ru> <1086780010.1051.106.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, hadi@cyberus.ca
In-Reply-To: <1086780010.1051.106.camel@jzny.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Due to single queue, I can't provide separate back
> > pressure for different access categories. What I do now, I do some
> > internal buffering and netif_stop_queue() when total number of packets
> > (or bytes) exceed some threshold. Of course, with watermarks to fight
> > jitter.
>
> Will work fine if you have mostly only one priority really.
Unfortunately, yes.
>
> > Let's consider real example. Some application do FTP transfer, lots of
> > data. Simultaneously, voice-over-IP connection invoked. Now question is:
> > how to assure voice quality?
>
> Non-trivial with current setup.
>
> > Accordingly to TGe, voice is send either with high
> > priority, or in TSPEC. If we will send all packets with high priority, we
> > will hit ourselves. If we can't provide some back pressure for low
> > priority traffic, it will block voice packets, since some moment you
> > should netif_stop_queue().
> >
> > Ideal would be if I can call netif_stop_queue(id), separately for each
> > id.
>
> Indeed.
> Looking at the transmit path code it seems doable.
> for each dev->id you also maintain a dev->id_state.
> We either use skb->fwmark or skb->priority to map to the different
BTW, what is fwmark? in 2.6.6 it is not present.
> dev->ids.
> The major challenge would be how to start the different queues once they
> are stopped. I suspect there is only tx completed interupt; i take it
> you can tell when each of the FIFOs is ready to swallow more packets?
Sure. I know when each DMA queue have space to accept new packets. w.r.t Tx 
discipline, it is really like 4 (taking into account TSPEC, see my mail about 
TGe, minimum 5 for STA and 6 (i did not said about power save buffering) for 
AP) independent devices.

I see you got the idea. Question is, how to implement it.
