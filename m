From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: Latency difference between fifo and pfifo_fast
Date: Wed, 7 Dec 2011 14:08:24 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF07@saturn3.aculab.com>
References: <CAA93jw58s4DG7Ow+j-cCgtD4UsWRUPZ-pbmeF1J1cZcaxCDRsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	<netdev@vger.kernel.org>, "Rick Jones" <rick.jones2@hp.com>
To: "Dave Taht" <dave.taht@gmail.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46314 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755803Ab1LGOIh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 09:08:37 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10570-02 for <netdev@vger.kernel.org>;
 Wed,  7 Dec 2011 14:08:34 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <CAA93jw58s4DG7Ow+j-cCgtD4UsWRUPZ-pbmeF1J1cZcaxCDRsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
...
> If he's hovering at close to line rate (wow), and yet experiencing
> serious delays on short traffic, perhaps what I describe 
> below may apply.
...
> 1) TCP grabs all the bandwidth it can. If you have no packet loss,
> it will eat more bandwidth, as rapidly as it can ramp up. 
> Until it eventually has packet loss.

The 'ramp up' may be part of the problem!
At a guess iSCSI is using the TCP connection to carry
many, separate, commands and responses. As such Nagle
will cause serious grief and is likely to be disabled.

TCP 'slow start' will apply whenever there is no unacked
data - which might be after any slight lull in the traffic.
IIRC (from looking at traces) Linux TCP will only send 4 data
packets following 'slow start' until it has received an ack.
Linux (at least some versions) will also delay sending an
ack until the next clock tick - rather than the traditional
scheme of always acking every other packet.

So if there are no responses, the requests can be delayed.
This will increase latency.

My suspicions (as I've said before) is that slow start
is broken for very low latency local networks.
Might be worth disabling it - but that is a massive system-wide
switch.

Very high packet rates can cause packet loss, but buying better
network infrastructure should mitigate that. In any case, 'slow
start' doesn't limit packet rate.

	David
