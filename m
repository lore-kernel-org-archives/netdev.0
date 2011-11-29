From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 17:06:23 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEF0@saturn3.aculab.com>
References: <CAA93jw7+KyX=7DC88hKisgaFtzn9vgLsBfUWOGhSHHPadw97Cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "John Fastabend" <john.r.fastabend@intel.com>,
	"Tom Herbert" <therbert@google.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: "Dave Taht" <dave.taht@gmail.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40926 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753200Ab1K2RIZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 12:08:25 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04717-07 for <netdev@vger.kernel.org>;
 Tue, 29 Nov 2011 17:08:21 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <CAA93jw7+KyX=7DC88hKisgaFtzn9vgLsBfUWOGhSHHPadw97Cg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
...
> We spent all that engineering time making TCP go fast and minimized
the
> hardware impact of that - why not spend a little more time - in the
> next generation of hw/sw - making TCP work *better* on the network?

One problem I've seen is that a lot of the 'make TCP go fast'
changes have been focused on bulk transfer over long(ish) latency
links - typical for ftp and http downloads.

Interactive (command+response) works moderately, but async
data requests suffer badly.

Typically these connections will have Nagle disabled (because
you can't stand the repeated timeouts), and may be between
very local systems so the RTT is efectively zero and packet
loss unexpected.
Under these conditions the 'slow start' and 'delayed acks'
conspire against you.

What is more, if you have a high request rate there is little
that can be done to merge tx packets, even the sender is
willing to let some data be queued until (say) the next 1ms
clock tick.

I have seen 30000 packets/sec on a single tcp connection!
(The sender doesn't know there is another message to send.)
The sender was a dual, running 'while :; do :; done'
reduced the packet count considerably!

	David
