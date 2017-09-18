From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RACK not getting disabled
Date: Mon, 18 Sep 2017 14:18:14 -0700
Message-ID: <1505769494.29839.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170918201428.GB28186@strugglingcoder.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hiren panchasara <hiren@strugglingcoder.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:47296 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750711AbdIRVSQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:18:16 -0400
Received: by mail-pf0-f176.google.com with SMTP id u12so879616pfl.4
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 14:18:16 -0700 (PDT)
In-Reply-To: <20170918201428.GB28186@strugglingcoder.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-09-18 at 13:14 -0700, hiren panchasara wrote:
> Hi all, I am trying to disable rack to see 3dupacks in action during
> loss-detection but based on the pcap, I see that it's still trigger
> loss-recovery on the first SACK (as if RACK is still enabled/active).
> 
> Here is what I did to disable rack:
> net.ipv4.tcp_recovery = 0
> 
> I've also disabled metrics:
> net.ipv4.tcp_no_metrics_save = 1 
> And also flushed existing entries with 'ip tcp_metrics flush' just to be
> on a safer side.
> 
> Not really relevant here but I've also switched to reno.
> 
> I am on: 4.10.0-33-generic
> pcap: https://transfer.sh/mfoiN/reno_no_rack.pcap
> 
> What am I missing? I can provide any additional info.
> 
> Cheers,
> Hiren


A single SACK can contains enough information to trigger a retransmit.

If you absolutely want to see the old 3 dupack in action, you also want
to disable SACK.
