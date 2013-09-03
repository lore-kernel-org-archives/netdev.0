From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN HW accel, performance advantage?
Date: Tue, 03 Sep 2013 08:29:10 -0700
Message-ID: <1378222150.7360.28.camel@edumazet-glaptop>
References: <OF00E35E7C.7482EC01-ONC1257BDB.00314AD0-C1257BDB.0031F6D0@transmode.se>
	 <1378216216.1545.1.camel@bwh-desktop.uk.level5networks.com>
	 <OF0F246C2A.B5DC5CA4-ONC1257BDB.004CA4E6-C1257BDB.004DB31E@transmode.se>
	 <1378219696.1545.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:47862 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755248Ab3ICPa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 11:30:28 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so6116867pdj.22
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 08:30:24 -0700 (PDT)
In-Reply-To: <1378219696.1545.9.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 15:48 +0100, Ben Hutchings wrote:

> GRO should be beneficial for bridges if you have bursty TCP streams.  It
> is especially beneficial if you also have TSO on the TX side.
> 
> Really you're going to have to try it and run benchmarks with your own
> hardware.

Note that ucc_geth does not have GRO support (it calls
netif_receive_skb())

It doesnt have RX checksuming either, so having to validate
tcp checksums (before aggregating them in GRO stack) would hurt if
packets only have to be forwarded.
