From: Josh Lehan <linux@krellan.com>
Subject: Skipping past TCP lost packet in userspace
Date: Mon, 30 May 2011 18:19:20 -0700
Message-ID: <4DE44218.4070306@krellan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server4.hostdango.com ([70.86.37.74]:32862 "EHLO
	server4.hostdango.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048Ab1EaCGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2011 22:06:20 -0400
Received: from transmat-4.krellan.net ([71.133.204.142] helo=[10.6.9.2])
	by server4.hostdango.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <linux@krellan.com>)
	id 1QRDc7-0008UJ-Je
	for netdev@vger.kernel.org; Mon, 30 May 2011 18:19:19 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.  I looked, but could not find an answer.  Is there already an
ioctl() or something like that in Linux, that would allow a userspace
TCP socket to skip past a lost packet?

The kernel already will continue to queue up packets, and with TCP SACK,
the kernel can acknowledge reception of further packets beyond the lost
packet, allowing the queue to continue growing.  However, all these
queued packets won't be delivered to userspace until the original lost
packet is received again, after it has been retransmitted.

Is there a way for a userspace program to prevent this needless stall?
It would be great if there was an ioctl() or similar call, that would
tell the kernel that it's OK to leave a gap in the data stream, and
resume supplying userspace with more data.  An obvious application would
be media streaming, and many high-level media protocols do their own
block framing anyway, so resynchronization after the data gap would not
be a problem.

This sounds like something that would be a FAQ, and if so, please point
me to the answer.  Thank you!

Josh Lehan
