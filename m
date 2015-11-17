From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: How to do TCP tx checksums
Date: Tue, 17 Nov 2015 10:26:47 -0800
Message-ID: <1447784807.22599.125.camel@edumazet-glaptop2.roam.corp.google.com>
References: <564A72D3.1050407@candelatech.com>
	 <CALx6S37AZz6UZctRxY9DOO+-x6MQ2gB9FQ2wSt8frEnegyh82Q@mail.gmail.com>
	 <564B677C.8000603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33883 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbbKQS0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 13:26:49 -0500
Received: by padhx2 with SMTP id hx2so16225211pad.1
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 10:26:48 -0800 (PST)
In-Reply-To: <564B677C.8000603@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-17 at 09:44 -0800, Ben Greear wrote:

> And in case it helps, here is the output from dmesg.
> 
> This is an Ethernet frame, and in this case csum-start is the
> index of the first byte of the TCP header as far as I can tell.
> 
> [64967.194251] check: 0xf51b  csum-start: 34  offset: 16 summed: 0x3  saddr: 0x201010a  daddr: 0x101010a len: 1514
> 

You forgot to clear tcp header @check before calling
__tcp_v4_send_check(), I think.

( th->check = 0; )


Anyway, just use trafgen and get ~6 Mpps, more easily than with pktgen.
