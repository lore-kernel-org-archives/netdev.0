From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: To netlink or not to netlink, that is the question
Date: Thu, 12 Jan 2017 09:14:40 -0800
Message-ID: <20170112091440.7f6cd41f@xeon-e3>
References: <CAHmME9pkktqOSUyTS_XhgC-CE4iqTv6UEA6w74kkm3xnBY8z9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33759 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750923AbdALROu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 12:14:50 -0500
Received: by mail-pf0-f171.google.com with SMTP id y143so16148819pfb.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:14:49 -0800 (PST)
In-Reply-To: <CAHmME9pkktqOSUyTS_XhgC-CE4iqTv6UEA6w74kkm3xnBY8z9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jan 2017 14:01:07 +0100
"Jason A. Donenfeld" <Jason@zx2c4.com> wrote:

> Hey folks,
> 
> A few months ago I switched away from using netlink in wireguard,
> preferring instead to use ioctl. I had come up against limitations in
> rtnetlink, and ioctl presented a straightforward hard to screw-up
> alternative. The very simple API is documented here:
> https://git.zx2c4.com/WireGuard/tree/src/uapi.h
> 
> This works well, and I'm reluctant to change it, but as I do more
> complicated things, and as kernel submission time looms nearer, I'm
> kept up at night by the notion that maybe I ought to give netlink
> another chance. But how?
> 
> For each wireguard interface, there are three types of structures for
> userspace to configure. There is one wgdevice for each interface. Each
> wgdevice has a variable amount (up to 2^16) of wgpeers. Each wgpeer
> has a variable amount (up to 2^16) of wgipmasks. I'd like an interface
> to get and set all of these at once, atomically.
> 
> Presently, with the ioctl, I just have a simple get ioctl and a simple
> set ioctl. The set one passes a user space pointer, which is read
> incrementally in kernel space. The get one will first return how much
> userspace should allocate, and then when called again will write
> incrementally into a provided userspace buffer up to a passed-in
> maximum number of bytes. Very basic, I'm quite happy.
> 
> When I had tried to do this priorly with netlink, I did it by defining
> changelink and fill_info in rtnl_link_ops. For changelink, I iterated
> through the netlink objects, and for fill_info, I filled in the skb
> with netlink objects. This was a bit more complex but basically
> worked. Except netlink skbs have a maximum size and are buffered,
> which means things broke entirely when trying to read or write logs of
> wgpeers or lots of wgipmasks. So, the meager interfaces afforded to me
> by rtnl_link_ops are insufficient. Doing anything beyond this, either
> by registering new rtnetlink messages, or by using generic netlink,
> seemed overwhelmingly complex and undesirable.
> 
> So I'm wondering -- is there a good way to be doing this with netlink?
> Or am I right to stay with ioctl?
> 
> Thanks,
> Jason

It is up to you but I doubt that code with new private ioctl's will be
accepted upstream. If you want full review then post for inclusion upstream.
If you just want to maintain it is a private fork, go ahead and do what
you want and suffer the consequences.
