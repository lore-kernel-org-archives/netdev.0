From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [E1000-devel] jitter / latency reduction
Date: Tue, 28 Mar 2017 18:07:59 -0700
Message-ID: <20170328180759.00006d92@intel.com>
References: <CACsfcop+P2jjzB7viMG-=6oZSDPU8qbCTDUYFtZ3527OVpZ90A@mail.gmail.com>
        <CAHX0N8tDmCBDiOuY34Sz50E+EwJexZ_E5R7qPn6s0+WCJRAZ=Q@mail.gmail.com>
        <CACsfcoqNbQ2RxkMnvyjjJZcOEEi6X-PZQo+US7dOgtKKa8_-oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Leonardo Amaral - Listas <listas@leonardoamaral.com.br>,
        <e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>
To: Mahmood Qazen <mqazen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:34227 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932571AbdC2BIB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 21:08:01 -0400
In-Reply-To: <CACsfcoqNbQ2RxkMnvyjjJZcOEEi6X-PZQo+US7dOgtKKa8_-oQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Mar 2017 08:09:42 -0800
Mahmood Qazen <mqazen@gmail.com> wrote:

> greetings Leonardo
> this is the slide / pdf I found and towards the end it asks if we
> could help.
> enjoy
> Mahmood -

Hi developers, thanks for your interest, we’d love to have help, but the
good/bad news is that this is implemented already upstream, and known as
busy_poll support in the kernel.  Also, most if not all the active
drivers right now, at least from heavily used drivers, support the
“built-in” model that busy poll has migrated to.  This allows most if
not all drivers with NAPI support (normal) in the kernel to have
busy_poll support if it is enabled at runtime.  I believe there is
currently some work to do still to get epoll working correctly, and
there probably is room for refactoring/improvement to solve some of
the issues with scaling.

There is also a paper being presented next week at the NetDevConf.org
conference about Busy Polling, by Eric Dumazet from google, and videos
will be posted eventually.


Please see (in the linux kernel source) Documentation/sysctl/net.txt
busy_read
----------------
Low latency busy poll timeout for socket reads. (needs
CONFIG_NET_RX_BUSY_POLL) Approximate time in us to busy loop waiting
for packets on the device queue. This sets the default value of the
SO_BUSY_POLL socket option. Can be set or overridden per socket by
setting socket option SO_BUSY_POLL, which is the preferred method of
enabling. If you need to enable the feature globally via sysctl, a
value of 50 is recommended. Will increase power usage.
Default: 0 (off)

busy_poll
----------------
Low latency busy poll timeout for poll and select. (needs
CONFIG_NET_RX_BUSY_POLL) Approximate time in us to busy loop waiting
for events. Recommended value depends on the number of sockets you poll
on. For several sockets 50, for several hundreds 100.
For more than that you probably want to use epoll.
Note that only sockets with SO_BUSY_POLL set will be busy polled,
so you want to either selectively set SO_BUSY_POLL on those sockets or
set sysctl.net.busy_read globally.
Will increase power usage.
Default: 0 (off)
