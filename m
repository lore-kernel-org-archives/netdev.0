From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH] net: add a tx_queue attribute rate_queue_limits in
 Mbps
Date: Mon, 24 Jun 2013 08:11:43 -0700
Message-ID: <20130624081143.7424f455@nehalam.linuxnetplumber.net>
References: <20130624032407.7546.96685.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, ben@decadent.org.uk,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:37146 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897Ab3FXPLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 11:11:49 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa11so11089976pad.5
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 08:11:48 -0700 (PDT)
In-Reply-To: <20130624032407.7546.96685.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Jun 2013 20:24:11 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> This adds a rate_queue_limit attribute to the tx_queue sysfs entry
> to allow rate limiting in units of Mpbs. Along with mqprio and BQL
> this provides another knob to tune queue performance. By default it
> is disabled with a setting of '0'.
> 
> By adding this as a queue attribute and _not_ a qdisc option allows
> using rate limits with qdisc schemes that may not align with tx rings
> and also allows using QOS schemes along with rate limits.
> 
> A sample implementation is provided for ixgbe. Any improvements or
> suggestions welcome I would also be interested to know if this works
> with other hardware and if Mbps is a good default unit.
> 
> I tested this briefly with iperf/netperf,
> 
> # echo 4000 > /sys/class/net/p3p2/queues/tx-0/tx_rate_limit
> # cat /sys/class/net/p3p2/queues/tx-0/tx_rate_limit
> 4000

I like the facility and there is a real need for it, but we need
to think about what best API for it is.

There are several possible API's for this. My preference in order is:
  1. Netlink: 
       PRO: most well structured and can notify control applications
       CON: doesn't propagate well down to device
  2. Ethtool:
       PRO: fits current model of speed/duplex
       CON: still and ioctl based model, non-extensible structures
  3. Sysfs
       PRO: easy to add
       CON: not a general mechanism, ends up being per-device
  4. Module parameter
       PRO: easy to code
       CON: hard to manage from application, hard to associate with multiple devices

     
