From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP performance regression
Date: Mon, 11 Nov 2013 06:27:49 -0800
Message-ID: <1384180069.16391.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <21120.27501.32323.332316@gargle.gargle.HOWL>
	 <1384149326.16391.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <21120.29720.673157.151074@gargle.gargle.HOWL>
	 <1384152853.16391.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <21120.37647.979237.40802@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dave Taht <dave.taht@gmail.com>
To: Sujith Manoharan <sujith@msujith.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:44206 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345Ab3KKO1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 09:27:51 -0500
Received: by mail-pd0-f170.google.com with SMTP id q10so1975190pdj.29
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 06:27:50 -0800 (PST)
In-Reply-To: <21120.37647.979237.40802@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-11 at 13:49 +0530, Sujith Manoharan wrote:

> I am not really clear on how this regression can be fixed in the driver
> since the majority of the transmission/aggregation logic is present in the
> TX completion path.

We have many choices.

1) Add back a minimum of ~128 K of outstanding bytes per TCP session,
   so that buggy drivers can sustain 'line rate'.

   Note that with 100 concurrent TCP streams, total amount of bytes
   queued on the NIC is 12 MB.
   And pfifo_fast qdisc will drop packets anyway.

   Thats what we call 'BufferBloat'

2) Try lower values like 64K. Still bufferbloat.

3) Fix buggy drivers, using a proper logic, or shorter timers (mvneta
case for example)

4) Add a new netdev attribute, so that well behaving NIC drivers do not
have to artificially force TCP stack to queue too many bytes in
Qdisc/NIC queues.
