From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Questions on XDP
Date: Thu, 16 Feb 2017 12:41:06 -0800
Message-ID: <CAKgT0Uc0RQyK0SCALEUVGBj8JMHCfp+CqiBsTJXN9mat9jUNjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:36424 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933086AbdBPUlI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 15:41:08 -0500
Received: by mail-it0-f48.google.com with SMTP id h10so4467317ith.1
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 12:41:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So I'm in the process of working on enabling XDP for the Intel NICs
and I had a few questions so I just thought I would put them out here
to try and get everything sorted before I paint myself into a corner.

So my first question is why does the documentation mention 1 frame per
page for XDP?  Is this with the intention at some point to try and
support page flipping into user space, or is it supposed to have been
for the use with an API such as the AF_PACKET mmap stuff?  If I am not
mistaken the page flipping has been tried in the past and failed, and
as far as the AF_PACKET stuff my understanding is that the pages had
to be mapped beforehand so it doesn't gain us anything without a
hardware offload to a pre-mapped queue.

Second I was wondering about supporting jumbo frames and scatter
gather.  Specifically if I let XDP handle the first 2-3K of a frame,
and then processed the remaining portion of the frame following the
directive set forth based on the first frame would that be good enough
to satisfy XDP or do I actually have to support 1 linear buffer
always.

Finally I was looking at xdp_adjust_head.  From what I can tell all
that is technically required to support it is allowing the head to be
adjusted either in or out.  I'm assuming there is some amount of
padding that is preferred.  With the setup I have currently I am
guaranteeing at least NET_SKB_PAD + NET_IP_ALIGN, however I have found
that there should be enough room for 192 bytes on an x86 system if I
am using a 2K buffer.  I'm just wondering if that is enough padding or
if we need more for XDP.

Anyway sorry for the stupid questions but I haven't been paying close
of attention to this and was mostly focused on the DMA bits needed to
support this so now I am playing catch-up.

- Alex
