From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Questions on XDP
Date: Sat, 18 Feb 2017 09:41:15 -0800
Message-ID: <1487439675.1311.96.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAKgT0Uc0RQyK0SCALEUVGBj8JMHCfp+CqiBsTJXN9mat9jUNjQ@mail.gmail.com>
         <58A62979.1050600@gmail.com> <20170218173402.1af86005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36251 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753035AbdBRRlS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 12:41:18 -0500
Received: by mail-pf0-f196.google.com with SMTP id c193so1761866pfb.3
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 09:41:18 -0800 (PST)
In-Reply-To: <20170218173402.1af86005@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-02-18 at 17:34 +0100, Jesper Dangaard Brouer wrote:
> On Thu, 16 Feb 2017 14:36:41 -0800
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
> > On 17-02-16 12:41 PM, Alexander Duyck wrote:
> > > So I'm in the process of working on enabling XDP for the Intel NICs
> > > and I had a few questions so I just thought I would put them out here
> > > to try and get everything sorted before I paint myself into a corner.
> > >   
> > > So my first question is why does the documentation mention 1 frame per
> > > page for XDP?  
> 
> Yes, XDP defines upfront a memory model where there is only one packet
> per page[1], please respect that!
> 
> This is currently used/needed for fast-direct recycling of pages inside
> the driver for XDP_DROP and XDP_TX, _without_ performing any atomic
> refcnt operations on the page. E.g. see mlx4_en_rx_recycle().


XDP_DROP does not require having one page per frame.

(Look after my recent mlx4 patch series if you need to be convinced)

Only XDP_TX is.

This requirement makes XDP useless (very OOM likely) on arches with 64K
pages.
