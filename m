From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next,1/2] net: Set sk_txhash from a random number
Date: Tue, 08 Dec 2015 05:15:59 -0800
Message-ID: <1449580559.7632.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438124526-2129341-2-git-send-email-tom@herbertland.com>
	 <566695D6.6060603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kernel-team@fb.com
To: Alexander Drozdov <al.drozdov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35425 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834AbbLHNQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 08:16:02 -0500
Received: by pfu207 with SMTP id 207so12175659pfu.2
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 05:16:01 -0800 (PST)
In-Reply-To: <566695D6.6060603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-08 at 11:33 +0300, Alexander Drozdov wrote:
> 29.07.2015 02:02, Tom Herbert wrote:
> > This patch creates sk_set_txhash and eliminates protocol specific
> > inet_set_txhash and ip6_set_txhash. sk_set_txhash simply sets a
> > random number instead of performing flow dissection. sk_set_txash
> > is also allowed to be called multiple times for the same socket,
> > we'll need this when redoing the hash for negative routing advice.
> It seems that this patch and some previous txhash-related
> ones break af_packet hash features for outgoing packets:
> - PACKET_FANOUT_HASH
> - TP_FT_REQ_FILL_RXHASH
> 
> af_packet now thinks that hashes for for incoming and outgoing
> packets of the same TCP stream differ. That is true for TCP
> sessions initiated by the host.

There never has been such guarantee. Even rx hashes for a single TCP
flow can differ, if packets are received on two different NIC with
different RSSS keys.
