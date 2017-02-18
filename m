From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Questions on XDP
Date: Sat, 18 Feb 2017 17:34:02 +0100
Message-ID: <20170218173402.1af86005@redhat.com>
References: <CAKgT0Uc0RQyK0SCALEUVGBj8JMHCfp+CqiBsTJXN9mat9jUNjQ@mail.gmail.com>
        <58A62979.1050600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>, brouer@redhat.com,
        David Miller <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56232 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753079AbdBRQeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 18 Feb 2017 11:34:09 -0500
In-Reply-To: <58A62979.1050600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Feb 2017 14:36:41 -0800
John Fastabend <john.fastabend@gmail.com> wrote:

> On 17-02-16 12:41 PM, Alexander Duyck wrote:
> > So I'm in the process of working on enabling XDP for the Intel NICs
> > and I had a few questions so I just thought I would put them out here
> > to try and get everything sorted before I paint myself into a corner.
> >   
> > So my first question is why does the documentation mention 1 frame per
> > page for XDP?  

Yes, XDP defines upfront a memory model where there is only one packet
per page[1], please respect that!

This is currently used/needed for fast-direct recycling of pages inside
the driver for XDP_DROP and XDP_TX, _without_ performing any atomic
refcnt operations on the page. E.g. see mlx4_en_rx_recycle().

This is also about controlling the cache-coherency state of the
struct-page cache-line.  (With two (or-more) packets per page,
the struct-page cache-line will be jumping around.) Controlling this is
essential when packets are transferred between CPUs. We need an
architecture were we can control this, please.

[1] https://prototype-kernel.readthedocs.io/en/latest/networking/XDP/design/requirements.html#page-per-packet

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
