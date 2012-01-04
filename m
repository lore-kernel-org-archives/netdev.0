From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: TCP communication for raw image transmission
Date: Wed, 4 Jan 2012 09:57:01 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF29@saturn3.aculab.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Jean-Michel Hautbois" <jhautbois@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53500 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753229Ab2ADJ6r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 04:58:47 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09444-05 for <netdev@vger.kernel.org>;
 Wed,  4 Jan 2012 09:58:41 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> I am currently working on a way to send raw images (~400*300 YUV
> 4:2:0) at a relative high speed (raw image and not compressed image
> due to specific codec issues).
> This would represent about 57MBps/sec on a 100Mbps ethernet link.
> This link is direct, nothing else will pass through it.
...
> I was thinking about using TCP socket (of course) ...

I'm not sure you get any benefit from using TCP (over UDP).
If any packets are lost (which on a dedicated network they
shouldn't be) then you probably can't stand the restransmit
delays - especially if the losses are systemic and repeated
in which case you'll occaisionally end up with very slow
throughput (when not enough packets are sent for the
out-of-sequence receives to request retransittions).

The TCP stack also has a series of 'features' that will
reduce the attainable throughput for this kind of traffic:
1) Nagle - easily turned off.
2) Slow start - only a global flag
3) Delayed acks - make 'slow start' more of a problem.

The code paths for UDP (sender and receiver) will be
much shorter, although you'll probably need to ensure
there is adequate buffering.

Also, it should be fairly easy to directly send the UDP
packets from withing the kernel completly bypassing the
normal UDP+IP parts of the network stack!
I know some people have done that completely in hardware
on some FPGA systems with slow cpus.

	David
