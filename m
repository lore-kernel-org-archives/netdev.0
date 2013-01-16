From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/5] soreuseport: infrastructure
Date: Wed, 16 Jan 2013 10:37:27 -0800
Message-ID: <CA+mtBx9UqyM-wTmX_ojNdH=oQO28i_4aV_z5mz1OiKJBzRRNnw@mail.gmail.com>
References: <alpine.DEB.2.00.1301141152130.3433@pokey.mtv.corp.google.com>
	<20130115075323.64b2fdc7@nehalam.linuxnetplumber.net>
	<1358266444.8744.5892.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:34822 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814Ab3APShb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 13:37:31 -0500
Received: by mail-ie0-f180.google.com with SMTP id c10so3215407ieb.11
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 10:37:30 -0800 (PST)
In-Reply-To: <1358266444.8744.5892.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ideally, we should chose a target given by the current CPU number, in
> case SYN messages are spread on all cpus or a set of cpus.
>
It is an ideal, but I don't readily see a practical way to do this
given the available information, the fact that number of sockets
created is up to the application, and the fact that there is no fixed
binding of a socket to CPU.

Consider the simple "cpu % num" algorithm in packet fanout.  Suppose
is a 16 CPU system, and RX queues for the NIC are processed on CPUS
0,3,7,11 and user creates 4 sockets.  In this configuration, on the
first socket would ever be selected!

Tom

> (same idea than PACKET_FANOUT_CPU in net/packet/af_packet.c)
>
>
>
>
