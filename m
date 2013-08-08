From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] veth: remove hardware checksum feature
Date: Wed, 07 Aug 2013 18:08:45 -0700
Message-ID: <1375924125.4004.83.camel@edumazet-glaptop>
References: <51F15E50.8080208@guap.ru> <5202E153.4060202@candelatech.com>
	 <1375920752.4004.71.camel@edumazet-glaptop>
	 <5202E510.9060309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Vitaly E. Lavrov" <lve@guap.ru>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35274 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755247Ab3HHBIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 21:08:49 -0400
Received: by mail-pa0-f44.google.com with SMTP id jh10so2782947pab.3
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 18:08:49 -0700 (PDT)
In-Reply-To: <5202E510.9060309@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-07 at 17:23 -0700, Ben Greear wrote:

> I am receiving the packet into user space by reading veth2
> using a packet socket, and then writing that packet out to eth6
> (e100e).  As far as I can tell, it reads from veth2 with bad checksum
> and then goes onto the wire with bad checksum.
> 

Then, when you read the packet socket, you probably have an indication
that checksum is to be computed or ignored.

Your application breaks because of this.

If forwarding was done by the kernel, the checksum would be filled
either by hardware, or core network helpers.

> Is it ever valid to *read* a packet with bad checksum though?  I thought
> the bogus bad hw-checksum issue was only on the tx-side as far as sniffing goes?

We have same flags on loopback interface.

So using your application on loopback should break the same ?

I am not saying your application is buggy, maybe we need a helper in
net/packet/af_packet.c. Please check TP_STATUS_CSUMNOTREADY

This was added 6 years ago in commit 8dc4194474159660
("[PACKET]: Add optional checksum computation for recvmsg")
