From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Horrid balance-rr bonding udp throughput
Date: Mon, 10 Apr 2017 12:31:09 -0700
Message-ID: <1491852669.10587.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <ea7fb030-f655-1658-14a6-6989e1e836ea@redhat.com>
         <6f08f174-b087-32b7-91dd-ca72db50bd04@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33660 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdDJTbL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 15:31:11 -0400
Received: by mail-pf0-f181.google.com with SMTP id s16so37779715pfs.0
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 12:31:11 -0700 (PDT)
In-Reply-To: <6f08f174-b087-32b7-91dd-ca72db50bd04@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-10 at 14:50 -0400, Jarod Wilson wrote:
> On 2017-04-08 7:33 PM, Jarod Wilson wrote:
> > I'm digging into some bug reports covering performance issues with 
> > balance-rr, and discovered something even worse than the reporter. My 
> > test setup has a pair of NICs, one e1000e, one e1000 (but dual e1000e 
> > seems the same). When I do a test run in LNST with bonding mode 
> > balance-rr and either miimon or arpmon, the throughput of the UDP_STREAM 
> > netperf test is absolutely horrible:
> > 
> > TCP: 941.19 +-0.88 mbits/sec
> > UDP: 45.42 +-4.59 mbits/sec
> > 
> > I figured I'd try LNST's packet capture mode, so exact same test, add 
> > the -p flag and I get:
> > 
> > TCP: 941.21 +-0.82 mbits/sec
> > UDP: 961.54 +-0.01 mbits/sec
> > 
> > Uh. What? So yeah. I can't capture the traffic in the bad case, but I 
> > guess that gives some potential insight into what's not happening 
> > correctly in either the bonding driver or the NIC drivers... More 
> > digging forthcoming, but first I have a flooded basement to deal with, 
> > so if in the interim, anyone has some insight, I'd be happy to hear it. :)
> 
> Okay, ignore the bit about bonding, I should have eliminated the bond 
> from the picture entirely. I think the traffic simply ended up on the 
> e1000 on the non-capture test and on the e1000e for the capture test, as 
> those numbers match perfectly with straight NIC to NIC testing, no bond 
> involved. That said, really odd that the e1000 is so severely crippled 
> for UDP, while TCP is still respectable. Not sure if I have a flaky NIC 
> or what...
> 
> For reference, e1000 to e1000e netperf:
> 
> TCP_STREAM: Measured rate was 849.95 +-1.32 mbits/sec
> UDP_STREAM: Measured rate was 44.73 +-5.73 mbits/sec

In our experiments, we found e1000e had latency issue with UDP packets,
not with TCP.

Try e1000e -> e1000e , problem should persist, right ?
