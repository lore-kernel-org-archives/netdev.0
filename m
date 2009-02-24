From: Oliver Zheng <mailinglists+netdev@oliverzheng.com>
Subject: TCP/IP stack interpretation of acceptable packet
Date: Tue, 24 Feb 2009 14:59:55 -0800
Message-ID: <2ff60cd60902241459q1de39054lb3dc5233f13b69c3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:61171 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760855AbZBXW77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 17:59:59 -0500
Received: by bwz5 with SMTP id 5so6244585bwz.13
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2009 14:59:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was investigating behaviour of the TCP/IP stacks and noticed that
Linux has a peculiarity. When a packet is received with the correct
sequence number but incorrect acknowledgement number (in my tests, it
was higher than the correct acknowledgement number), the stack accepts
the packet as a valid packet and passes the data up to the application
(I do not know whether the ack information is accepted). According to
the list of tests described here in the TCP RFC 793 [1], accepting a
packet requires the packet to satisfy both sequence and
acknowledgement number tests; otherwise, the entirety of the packet
(its data and its acknowledgement information confirming reception of
previous data) should be dropped. Is this intentional, a bug, or am I
misinterpreting something? A nice flow chart that explains this
procedure is here [2].

Not to instigate flame, but Windows does this correctly, or at least
correctly in my interpretation of the spec.

[1] http://tools.ietf.org/html/rfc793#page-69
[2] http://www.medianet.kent.edu/techreports/TR2005-07-22-tcp-EFSM.pdf (page 17)

Cheers,
Oliver
