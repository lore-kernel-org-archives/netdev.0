From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: Re: [PATCH net-next 0/9] alx: add multi queue support
Date: Mon, 24 Oct 2016 14:54:32 +0200
Message-ID: <20161024125432.GA8171@localhost.localdomain>
References: <cover.1477044917.git.tobias.regnery@gmail.com>
 <CAMXMK6uPw7N+sve+gePm8ToDaoH7dciWq7ixZQOxpQZ5jr=yOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: Chris Snook <chris.snook@gmail.com>, jcliburn@gmail.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33850 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934873AbcJXMyf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 08:54:35 -0400
Received: by mail-wm0-f67.google.com with SMTP id d199so9725375wmd.1
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 05:54:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAMXMK6uPw7N+sve+gePm8ToDaoH7dciWq7ixZQOxpQZ5jr=yOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tested this patchset with my AR8161 ethernet card in different situations:

  - After two weeks of daily use I observed no regression with this patchset.
  - I manually tested the new error paths in the __alx-open function and in
    the other newly added device bringup functions.

  - iperf udp and tcp throughput are exactly the same with and without this
    patchset, regardless of the number of parallel streams.
  - netperf TCP_RR and UDP_RR tests shows a slight performance increase of
    about 1-2% with this patchset.

I don't own any of the other supported cards by the driver, so if someone is
willing to test these patches on one of the other cards, this is highly
appreciated.

Benefits are the split between misc interrupts and the tx / rx interrupts
with the new msi-x support and better multi core cpu utilization.

Sorry for not providing these information in the patchset, I will add these
in the next revision.

--
Tobias

On 21.10.16, Chris Snook wrote:
> Can you please elaborate on the testing and benefits?
> 
> - Chris
> 
> On Fri, Oct 21, 2016 at 3:50 AM Tobias Regnery <tobias.regnery@gmail.com>
> wrote:
> 
> > This patchset lays the groundwork for multi queue support in the alx driver
> > and enables multi queue support for the tx path by default. The hardware
> > supports up to 4 tx queues.
> >
> > The rx path is a little bit harder because apparently (based on the limited
> > information from the downstream driver) the hardware supports up to 8 rss
> > queues but only has one hardware descriptor ring on the rx side. So the rx
> > path will be part of another patchset.
> >
> > This work is based on the downstream driver at github.com/qca/alx
> >
> > I had a hard time splitting these changes up into reasonable parts because
> > this is my first bigger kernel patchset, so please be patient if this is
> > not
> > the right approach.
> >
> > Tobias Regnery (9):
> >   alx: refactor descriptor allocation
> >   alx: extend data structures for multi queue support
> >   alx: add ability to allocate and free alx_napi structures
> >   alx: switch to per queue data structures
> >   alx: prepare interrupt functions for multiple queues
> >   alx: prepare resource allocation for multi queue support
> >   alx: prepare tx path for multi queue support
> >   alx: enable msi-x interrupts by default
> >   alx: enable multiple tx queues
> >
> >  drivers/net/ethernet/atheros/alx/alx.h  |  36 ++-
> >  drivers/net/ethernet/atheros/alx/main.c | 554
> > ++++++++++++++++++++++----------
> >  2 files changed, 420 insertions(+), 170 deletions(-)
> >
> > --
> > 2.7.4
> >
> >
