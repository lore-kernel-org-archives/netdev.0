From: Tom Herbert <therbert@google.com>
Subject: Re: FOU RX interface?
Date: Thu, 2 Oct 2014 07:44:55 -0700
Message-ID: <CA+mtBx_LphKn54F8sVbOqZBbbb9aGda4Kdc-pKhq4yxGk=6GvQ@mail.gmail.com>
References: <CALCETrXPKRm16avRoDFtE6-o+x-=n4Xq1BTZsbzkUYLTLOeXVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:34496 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507AbaJBOo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 10:44:56 -0400
Received: by mail-ie0-f177.google.com with SMTP id rd18so2635188iec.22
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 07:44:56 -0700 (PDT)
In-Reply-To: <CALCETrXPKRm16avRoDFtE6-o+x-=n4Xq1BTZsbzkUYLTLOeXVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 10:14 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> Hi-
>
> Sorry for the lack of proper threading here -- I lost the original message.
>
> If I'm understanding the FOU use case correctly, if I set up a FOU
> tunnel tun0 that is encapsulated in UDP on eth0, then tun0 packets
> will be transmitted on tun0, but incoming packets will show up on eth0
> when they're reinjected after stripping the FOU header.
>
Incoming FOU packets will still land on the tunnel interface. In FOU
RX the UDP packet is removed and logically re-injected into the
stack-- at this point the packet is IPIP in IP (or sit, GRE) so
appropriate tunnel protocol processing occurs.

> Is this right?  I think that, without a way to reinject the received
> packets on the tunnel interface, using FOU will be annoying.  For
> example, writing firewall rules might be tricky.  And programs that
> use packet sockets or SO_BINDTODEVICE could have a hard time being
> configured such that they notice the received packets.
>
I believe it should work.

> Also, is it even possible to assign a FOU tunnel to a different
> network namespace than the device that's being tunneled over?  How
> will the received packets end up in the right netns?
>
Anything you can do with IP tunnels, you should be able to with FOU
enabled IP tunnels. FOU is transparent to IP tunnels on RX.

> --Andy
