From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: cross namespace interface notification for tun devices
Date: Wed, 20 Sep 2017 22:13:27 +0200
Message-ID: <CAHmME9rLB2uQJUrPVvxiGzvTxUBJOOPoBWLU5ycjgx8VYZG5_Q@mail.gmail.com>
References: <CAHmME9pD_kees+xrjTeWXgi26UdhbMVgvoddbCyueTZkbguvAg@mail.gmail.com>
 <CAM_iQpVvDNRbtj_47_3XXa_ezyrT=a_VzDtK5SCR9a4_2Gqw9w@mail.gmail.com>
 <CAHmME9oSZeAoDtSLxoGiEcTcCbmPLf-nj3OJcJ1ma8fs4BWQAw@mail.gmail.com> <CAM_iQpXhjuh5NJJiAwBJG4EpkWXWz74WS7RFjt5L1mDV9nKTVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>, Mathias <mathias@hall-andersen.dk>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:35395 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750919AbdITUNb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 16:13:31 -0400
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id e2cb3fd9
        for <netdev@vger.kernel.org>;
        Wed, 20 Sep 2017 20:05:16 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id e28a11c9 (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Wed, 20 Sep 2017 20:05:14 +0000 (UTC)
Received: by mail-io0-f176.google.com with SMTP id l15so6261873iol.8
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 13:13:29 -0700 (PDT)
In-Reply-To: <CAM_iQpXhjuh5NJJiAwBJG4EpkWXWz74WS7RFjt5L1mDV9nKTVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 8:29 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Sounds like we should set NETIF_F_NETNS_LOCAL for tun
> device.

Absolutely do not do this under any circumstances. This would be a
regression and would break API compatibility. As I wrote in my first
email, it's already possible to sleep-loop for that information using
the tun device's fd; I'm just looking for a better event-based
approach.

> What is your legitimate use case of send/receive packet to/from
> a tun device in a different netns?

Because sometimes it's very nice to be able to move network interfaces
that use tun devices into different namespaces, for some xnamespace
proxying.

What Dan described in the email he just sent is exactly this use case.

In WireGuard (a kernel thing), I have facilities for this --
https://www.wireguard.com/netns/ . Now I'm working on the userspace
version and would like to expose the same utility.

Anyway, the purpose of me sending this message to the list was not to
question the "legitimacy" of my application usage, but rather to
elicit feedback on two specific things:

1. to determine if there's already a mechanism in place for this that
I've overlooked; and
2. to determine particularities of me implementing a mechanism, if
it's not already there.

I'm slightly more convinced that there isn't currently a mechanism for
this. It seems like the easiest way, therefore, would be some kind of
control message that could be poll'd for, using the existing
per-process fd. That way there wouldn't be any violations of the
current namespace situation, yet processes could still get event
notifications as needed.
