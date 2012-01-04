From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Wed, 4 Jan 2012 12:16:56 +0100
Message-ID: <CAL8zT=g-f5Ax5WjkxxzfhN7ZDBgRMXFpZq8EKoDG3b9S0Z7dYg@mail.gmail.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6D8AF29@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53116 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351Ab2ADLRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 06:17:18 -0500
Received: by wgbdr13 with SMTP id dr13so28872930wgb.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 03:17:17 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF29@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/4 David Laight <David.Laight@aculab.com>:
>
>> I am currently working on a way to send raw images (~400*300 YUV
>> 4:2:0) at a relative high speed (raw image and not compressed image
>> due to specific codec issues).
>> This would represent about 57MBps/sec on a 100Mbps ethernet link.
>> This link is direct, nothing else will pass through it.
> ...
>> I was thinking about using TCP socket (of course) ...
>
> I'm not sure you get any benefit from using TCP (over UDP).
> If any packets are lost (which on a dedicated network they
> shouldn't be) then you probably can't stand the restransmit
> delays - especially if the losses are systemic and repeated
> in which case you'll occaisionally end up with very slow
> throughput (when not enough packets are sent for the
> out-of-sequence receives to request retransittions).

UDP is interesting for the fast path (you mention it later) but it has
some drawbacks, with one being packet loss.
Today, it is a dedicated link, but maybe will I use a switch also, and
the problem would exist.
I can't say (I will try tomorrow) if this would be really more
efficient on my board BTW.
If this is a HW issue then, UDP or TCP will be limited in the same way.

> The TCP stack also has a series of 'features' that will
> reduce the attainable throughput for this kind of traffic:
> 1) Nagle - easily turned off.
> 2) Slow start - only a global flag
> 3) Delayed acks - make 'slow start' more of a problem.
>
> The code paths for UDP (sender and receiver) will be
> much shorter, although you'll probably need to ensure
> there is adequate buffering.
>
> Also, it should be fairly easy to directly send the UDP
> packets from withing the kernel completly bypassing the
> normal UDP+IP parts of the network stack!
> I know some people have done that completely in hardware
> on some FPGA systems with slow cpus.

You mean using a layer 2 protocol with specific ethertype and raw
sockets for instance ?

JM
