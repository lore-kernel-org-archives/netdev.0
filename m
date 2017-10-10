From: "Sergey K." <simkergey@gmail.com>
Subject: High CPU load by native_queued_spin_lock_slowpath
Date: Tue, 10 Oct 2017 18:00:19 +0600
Message-ID: <CAGv8E+xZOweXEedymRuLt4idQmCM8Mk1TZOM=0p3YmnXbh-n+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:48377 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755349AbdJJMAU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 08:00:20 -0400
Received: by mail-it0-f48.google.com with SMTP id c3so2034601itc.3
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 05:00:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm using Debian 9(stretch edition) kernel 4.9., hp dl385 g7 server
with 32 cpu cores. NIC queues are tied to processor cores. Server is
shaping traffic (iproute2 and htb discipline + skbinfo + ipset + ifb)
and filtering some rules by iptables.

At that moment, when traffic goes up about 1gbit/s cpu is very high
loaded. Perf tool tells me that kernel module
native_queued_spin_lock_slowpath loading cpu about 40%.

After several hours of searching, I found that if I remove the htb
discipline from ifb0, the high load goes down.
Well, I think that problem with classify and shaping by htb.

Who knows how to solve?
