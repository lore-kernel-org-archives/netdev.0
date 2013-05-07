From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [RFC 1/2] netmap: infrastructure (in staging)
Date: Tue, 7 May 2013 13:20:31 -0400
Message-ID: <CAAsGZS74kd+XW221+FHB75fss=_2Ghwj93ekYcPceqYns8HdRw@mail.gmail.com>
References: <20130419.155859.1092595631804890737.davem@davemloft.net>
	<20130419131632.31fce894@nehalam.linuxnetplumber.net>
	<1366403483.16391.59.camel@edumazet-glaptop>
	<20130419.163831.1434224426107133131.davem@davemloft.net>
	<20130419134925.4981bdfc@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	gregkh@linuxfoundation.org, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:63963 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754585Ab3EGRUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 13:20:33 -0400
Received: by mail-la0-f53.google.com with SMTP id eo20so837184lab.12
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 10:20:31 -0700 (PDT)
In-Reply-To: <20130419134925.4981bdfc@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 4:49 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:

>
> I get 7Mpps (single queue) with ixgbe and pktgen.
> Easily hit 14.8 Mpps (single queue) with netmap.
>
> The real problem is that DPDK and netmap can do multiple packets per request
> to driver. Right now their is one PCI bus transaction per packet with current
> driver model.
>

Look @ tpacket_v3 and you will realize that you can easily transfer a
block of packets. A block_descriptor(either the one we have or a
variant of this) is all you need when you are doing real_life packet
capture/transmit. Sure you might have a need to add other packet
descriptors but then it's easy to achieve. The tpacket_v3
block-descriptor(not packet descriptor) even has some fields that even
the state of the art FPGAs didn't have on them when I first started
venturing out in this space.

As far as coalescing PCIe transactions are concerned, it also depends
how much buffer the NIC/NPU/FPGA has. Cheap NICs don't have onboard
buffer so they can't absorb the spikes and batch small transfers. If
we test a NIC w/ another NIC it's not going to tell the whole story. A
simple spirent test will expose this.
