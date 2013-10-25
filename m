From: "David Laight" <David.Laight@ACULAB.COM>
Subject: Odd SCTP behaviour after remote host reboot.
Date: Fri, 25 Oct 2013 11:19:39 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73B3@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44959 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752525Ab3JYKWB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 06:22:01 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 05556-03 for <netdev@vger.kernel.org>;
 Fri, 25 Oct 2013 11:21:58 +0100 (BST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've just been given a very odd Wireshark trace from a customer.

There is a single SCTP association with src_port==dst_port=5104 (m3ua).
The remote system is reset and establishes a new association with the
same port numbers.
(The trace shows init/init_ack/cookie/cookie_ack with new verification tags.)
However the data seems to have been linked back to the original socket!
There are no further packets sent with the old verification tag.

This isn't what I expect, and seems inappropriate for a reliable transport.

The kernel they are running is old - 2.6.18-164 RHEL 5 update 4 from 2009!
My guess is that it won't include any SCTP updates - so the latest RHEL 5
kernel (2.6.18-358) won't be any better.

Any idea when this might have been fixed?
If they want to use RH, the latest kernel is based on 2.6.32.

	David
