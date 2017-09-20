From: Dan Williams <dcbw@redhat.com>
Subject: Re: cross namespace interface notification for tun devices
Date: Wed, 20 Sep 2017 14:57:34 -0500
Message-ID: <1505937454.9403.2.camel@redhat.com>
References: <CAHmME9pD_kees+xrjTeWXgi26UdhbMVgvoddbCyueTZkbguvAg@mail.gmail.com>
         <CAM_iQpVvDNRbtj_47_3XXa_ezyrT=a_VzDtK5SCR9a4_2Gqw9w@mail.gmail.com>
         <CAHmME9oSZeAoDtSLxoGiEcTcCbmPLf-nj3OJcJ1ma8fs4BWQAw@mail.gmail.com>
         <CAM_iQpXhjuh5NJJiAwBJG4EpkWXWz74WS7RFjt5L1mDV9nKTVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Mathias <mathias@hall-andersen.dk>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60534 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751436AbdITT5g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 15:57:36 -0400
In-Reply-To: <CAM_iQpXhjuh5NJJiAwBJG4EpkWXWz74WS7RFjt5L1mDV9nKTVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-20 at 11:29 -0700, Cong Wang wrote:
> On Tue, Sep 19, 2017 at 2:02 PM, Jason A. Donenfeld <Jason@zx2c4.com>
> wrote:
> > On Tue, Sep 19, 2017 at 10:40 PM, Cong Wang <xiyou.wangcong@gmail.c
> > om> wrote:
> > > By "notification" I assume you mean netlink notification.
> > 
> > Yes, netlink notification.
> > 
> > > The question is why does the process in A still care about
> > > the device sitting in B?
> > > 
> > > Also, the process should be able to receive a last notification
> > > on IFF_UP|IFF_RUNNING before device is finally moved to B.
> > > After this point, it should not have any relation to netns A
> > > any more, like the device were completely gone.
> > 
> > That's very clearly not the case with a tun device. Tun devices
> > work
> > by letting a userspace process control the inputs (ndo_start_xmit)
> > and
> > outputs (netif_rx) of the actual network device. This controlling
> > userspace process needs to know when its own interface that it
> > controls goes up and down. In the kernel, we can do this by just
> > checking dev->flags&IFF_UP, and receive notifications on ndo_open
> > and
> > ndo_stop. In userspace, the controlling process looses the ability
> > to
> > receive notifications like ndo_open/ndo_stop when the interface is
> > moved to a new namespace. After the interface is moved to a
> > namespace,
> > the process will still control inputs and ouputs (ndo_start_xmit
> > and
> > netif_rx), but it will no longer receive netlink notifications for
> > the
> > equivalent of ndo_open and ndo_stop. This is problematic.
> 
> Sounds like we should set NETIF_F_NETNS_LOCAL for tun
> device.
> 
> What is your legitimate use case of send/receive packet to/from
> a tun device in a different netns?

One thought: run openvpn in the master netns, but put its tun0
interface into an application's netns.  Per-application VPN,
essentially?  Or maybe that's not how people do this kind of thing, but
it's a thought.

Dan
