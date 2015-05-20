From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet capturing performance
Date: Wed, 20 May 2015 08:06:45 -0700
Message-ID: <1432134405.4060.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHQdsZ-KmL-ksQzHni6ZbfREaZ7sumFkjh5qLwEwd+pdYWFsLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Deniz Eren <denizlist@denizeren.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36451 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430AbbETPGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 11:06:48 -0400
Received: by pabts4 with SMTP id ts4so70089894pab.3
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 08:06:47 -0700 (PDT)
In-Reply-To: <CAHQdsZ-KmL-ksQzHni6ZbfREaZ7sumFkjh5qLwEwd+pdYWFsLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 16:13 +0300, Deniz Eren wrote:

> But after some investigation and some advice from more expert people
> the problem seems to be pf_packet sockets overhead. But I don't know
> exactly where is the bottleneck. Do you have any idea exactly where
> could be the bottleneck?

You use a multi queue NIC.

Make sure you setup proper IRQ affinities to serve IRQ in a sharded way.

The key is to try to have one packet queue to receive a copy of the
sniffed traffic per cpu.

AF_PACKET has PACKET_FANOUT / PACKET_FANOUT_CPU capability.
