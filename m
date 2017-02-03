From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: Inconsistency in packet drop due to MTU (eth vs veth)
Date: Fri, 3 Feb 2017 23:42:32 +0900
Message-ID: <1c93d9f3-bb4b-909e-d3da-2b6d42bfbca2@gmail.com>
References: <159b79aa979.e23be6a5186096.2767722456700391441@gmail.com>
 <1484852027.16328.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <159f4b9e4ab.12b79bda8122843.8859202944513905410@gmail.com>
 <1485880029.6360.118.camel@edumazet-glaptop3.roam.corp.google.com>
 <15a0303f544.b70bc5d115840.1387609337770969373@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <cwang@twopensource.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Vijay Pandurangan <vijayp@vijayp.ca>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        ebiederm <ebiederm@aristanetworks.com>
To: Fredrik Markstrom <fredrik.markstrom@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <15a0303f544.b70bc5d115840.1387609337770969373@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/02/03 (金) 17:07, Fredrik Markstrom wrote:
>  ---- On Tue, 31 Jan 2017 17:27:09 +0100 Eric Dumazet <eric.dumazet@gmail.com> wrote ----
>  > On Tue, 2017-01-31 at 14:32 +0100, Fredrik Markstrom wrote:
>  > >  ---- On Thu, 19 Jan 2017 19:53:47 +0100 Eric Dumazet <eric.dumazet@gmail.com> wrote ----
>  > >  > On Thu, 2017-01-19 at 17:41 +0100, Fredrik Markstrom wrote:
>  > >  > > Hello,
>  > >  > >
>  > >  > > I've noticed an inconsistency between how physical ethernet and
>  > > veth handles mtu.
>  > >  > >
>  > >  > > If I setup two physical interfaces (directly connected) with
>  > > different mtu:s, only the size of the outgoing packets are limited by
>  > > the mtu. But with veth a packet is dropped if the mtu of the receiving
>  > > interface is smaller then the packet size.
>  > >  > >
>  > >  > > This seems inconsistent to me, but maybe there is a reason for
>  > > it ?
>  > >  > >
>  > >  > > Can someone confirm if it's a deliberate inconsistency or just a
>  > > side effect of using dev_forward_skb() ?
>  > >  >
>  > >  > It looks this was added in commit
>  > >  > 38d408152a86598a50680a82fe3353b506630409
>  > >  > ("veth: Allow setting the L3 MTU")
>  > >  >
>  > >  > But what was really needed here was a way to change MRU :(
>  > >
>  > > Ok, do we consider this correct and/or something we need to be
>  > > backwards compatible with ? Is it insane to believe that we can fix
>  > > this "inconsistency" by removing the check ?
>  > >
>  > > The commit message reads "For consistency I drop packets on the
>  > > receive side when they are larger than the MTU", do we know what it's
>  > > supposed
>  > > to be consistent with or is that lost in history ?
>  >
>  > There is no consistency among existing Ethernet drivers.
>  >
>  > Many ethernet drivers size the buffers they post in RX ring buffer
>  > according to MTU.
>  >
>  > If MTU is set to 1500, RX buffers are sized to be about 1536 bytes,
>  > so you wont be able to receive a 1700 bytes frame.
>  >
>  > I guess that you could add a specific veth attribute to precisely
>  > control MRU, that would not break existing applications.
>
> Ok, I will propose a patch shortly. And thanks, your response time is
> awesome !

But why do you want to configure MRU?
What is the problem with setting MTU instead.

Toshiaki Makita
