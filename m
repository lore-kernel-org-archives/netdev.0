From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] liquidio: improve UDP TX performance
Date: Wed, 22 Feb 2017 05:52:26 -0800
Message-ID: <1487771546.9415.49.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170221210907.GA8045@felix.cavium.com>
         <CALx6S35HE=8bwXMy7U=+kOSaP1fBmRjPUKn1neW6O=h38P0K2A@mail.gmail.com>
         <20170222065737.GA1201@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com,
        VSR Burru <veerasenareddy.burru@cavium.com>
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36199 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932120AbdBVNw3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 08:52:29 -0500
Received: by mail-pg0-f66.google.com with SMTP id z128so483938pgb.3
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 05:52:29 -0800 (PST)
In-Reply-To: <20170222065737.GA1201@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-21 at 22:57 -0800, Felix Manlunas wrote:
> Tom Herbert <tom@herbertland.com> wrote on Tue [2017-Feb-21 15:27:54 -0800]:
> > On Tue, Feb 21, 2017 at 1:09 PM, Felix Manlunas
> > <felix.manlunas@cavium.com> wrote:
> > > From: VSR Burru <veerasenareddy.burru@cavium.com>
> > >
> > > Improve UDP TX performance by:
> > > * reducing the ring size from 2K to 512
> > 
> > It looks like liquidio supports BQL. Is that not effective here?
> 
> Response from our colleague, VSR:
> That's right, BQL is not effective here.  We reduced the ring size because
> there is heavy overhead with dma_map_single every so often.  With iommu=on,
> dma_map_single in PF Tx data path was taking longer time (~700usec) for
> every ~250 packets.  Debugged intel_iommu code, and found that PF driver is
> utilizing too many static IO virtual address mapping entries (for gather
> list entries and info buffers): about 100K entries for two PF's each using
> 8 rings.  Also, finding an empty entry (in rbtree of device domain's iova
> mapping in kernel) during Tx path becomes a bottleneck every so often; the
> loop to find the empty entry goes through over 40K iterations; this is too
> costly and was the major overhead.  Overhead is low when this loop quits
> quickly.

This is exactly the information that should be in the changelog ;)
