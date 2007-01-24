From: kristrev@student.matnat.uio.no
Subject: Retransmission and packet handling in the TCP-code
Date: Wed, 24 Jan 2007 11:24:04 +0100 (CET)
Message-ID: <56730.129.240.228.21.1169634244.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:46611 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751062AbXAXKhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 05:37:33 -0500
Received: from mail-mx4.uio.no ([129.240.10.45])
	by pat.uio.no with esmtp (Exim 4.63)
	(envelope-from <kristrev@ulrik.uio.no>)
	id 1H9fIb-0000TD-Al
	for netdev@vger.kernel.org; Wed, 24 Jan 2007 11:24:13 +0100
Received: from smtp.uio.no ([129.240.10.9] helo=mail-mx4.uio.no)
	by mail-mx4.uio.no with esmtp (Exim 4.63)
	(envelope-from <kristrev@ulrik.uio.no>)
	id 1H9fIS-0005dV-A0
	for netdev@vger.kernel.org; Wed, 24 Jan 2007 11:24:13 +0100
Received: from mail-web2.uio.no ([129.240.10.19] helo=webmail.uio.no)
	by mail-mx4.uio.no with esmtp (Exim 4.63)
	(envelope-from <kristrev@ulrik.uio.no>)
	id 1H9fIS-0005dS-7x
	for netdev@vger.kernel.org; Wed, 24 Jan 2007 11:24:04 +0100
References: 
In-Reply-To: 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have recently started working with the Linux-kernel TCP-code with
regards to implementing a few (hopefully good) algorithms. But I want to
make sure that I have understood everything correctly before I start
implementing, so I have a few questions.

1. Are the skb's aware of the sk_buff_head? E.g. does the prev pointer of
the last skb (the one that buff_head->next points to) in the write queue
point to buff_head or to the first skb?

2. Is the "only" thing that seperates a for instance lost packet from a
recently queued one the value of the tcp_skb_cb->sacked-variable (from the
kernels point of view)? (Except for the fact that send_head might point to
the recently queued one).

3. When a retransmission occur, are all the lost packets resent or just
n-1 of them? A couple of my friends claim that the latter is true, but I
can't find anything in the source code to support that. My theory is that
they (my friends) don't count the packet that triggers the retransmission,
even though this is also retransmitted.

4. Does the kernel bundle two and two packets (if possible) during
retransmission? The same friends that told me about the n-1-thing, also
told me that the kernel tries to bundle as many packets as possible.

But I can't find anything in the code to support this, as far as can see
it tries to bundle two packets (skb's) and sends the new packet (or this
first one, if the collapse wasnt succsessful) to tcp_transmit_skb() (and
then it is to late to bundle any more).

5. Say that you have sent three packets (called p1, p2 and p3) and p2
arrives succsessfully, but p1 doesn't and triggers a timeout. If I have
understod the code correctly, the kernel will try to collapse p1 and p3
and send the combined packet if successfully (or just p1).

If we assume that the collapse took place and that p3 got lost, how does
the reciever detect what part of the data (in the packet) belongs to p1
and p3? To me it seems that tcp_retrans_try_collapse() appends all the
data from (in this case) p3 to the data-field of p1, without e.g. marking
that the last 25 bytes belongs to p3.

Thanks in advance for any answers and have a good day :)

-Kristian

