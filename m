From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 16:39:22 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF21@saturn3.aculab.com>
References: <1324483543.2301.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <monstr@monstr.eu>, "David Miller" <davem@davemloft.net>,
	"John Williams" <john.williams@petalogix.com>,
	<netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Jun Zhao" <mypopydev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42976 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751716Ab1LUQkz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 11:40:55 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20028-02 for <netdev@vger.kernel.org>;
 Wed, 21 Dec 2011 16:40:49 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1324483543.2301.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> If not, a malicious attacker could send 1-byte frames and exhaust your
> kernel memory.

That used to happen in SVR4 - it was possible for single byte TCP (etc)
data to be queued at a STREAM head (which counted actual data bytes)
in a 2k message block.
Actually we also managed to use all kernel memory queueing zero sized
STREAMS messages.

> If you want to reduce it, you might use copybreak : Some drivers copy
> the data into a small skb instead of providing a jumbo frame to upper
> stack.

Many, many moons ago I wrote an ethernet driver that received into
an array of 128 (mostly) 512byte buffers. Full sized frames would have
multiple rx ring entries, but could almost always be copied into a
correctly
sized buffer with a single aligned copy (cache-line aligned if useful).
This was significantly faster than other schemes - especially
on systems where the iommu needed setting to allow the ethernet
hardware to access memory.

I don't know if the linux skb buffers would allow the ethernet
driver to use (say) 1600 byte rx buffers, and link them together
when a long frame arrives. Most ethernet HW I've seen will
fragment long receives.

The painful hardware is that which enforces a 4n byte alignment
on the rx buffer! - on systens that can't do misaligned accesses.
2 bytes of junk would be fine!

	David
