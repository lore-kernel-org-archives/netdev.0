From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: High CPU load by native_queued_spin_lock_slowpath
Date: Tue, 10 Oct 2017 07:07:12 -0700
Message-ID: <1507644432.31614.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAGv8E+xZOweXEedymRuLt4idQmCM8Mk1TZOM=0p3YmnXbh-n+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Sergey K." <simkergey@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:37375 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755981AbdJJOHO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 10:07:14 -0400
Received: by mail-pf0-f195.google.com with SMTP id z80so17400718pff.4
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 07:07:13 -0700 (PDT)
In-Reply-To: <CAGv8E+xZOweXEedymRuLt4idQmCM8Mk1TZOM=0p3YmnXbh-n+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-10 at 18:00 +0600, Sergey K. wrote:
> I'm using Debian 9(stretch edition) kernel 4.9., hp dl385 g7 server
> with 32 cpu cores. NIC queues are tied to processor cores. Server is
> shaping traffic (iproute2 and htb discipline + skbinfo + ipset + ifb)
> and filtering some rules by iptables.
> 
> At that moment, when traffic goes up about 1gbit/s cpu is very high
> loaded. Perf tool tells me that kernel module
> native_queued_spin_lock_slowpath loading cpu about 40%.
> 
> After several hours of searching, I found that if I remove the htb
> discipline from ifb0, the high load goes down.
> Well, I think that problem with classify and shaping by htb.
> 
> Who knows how to solve?

You use a single ifb0 on the whole (multiqueue) device for ingress ?

What about multiple ifb instead, one per RX queue ?

Alternative is to reduce contention and use a single RX queue.
