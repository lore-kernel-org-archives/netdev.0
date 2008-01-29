From: kristrev@student.matnat.uio.no
Subject: SKBs with shared fragments
Date: Tue, 29 Jan 2008 17:17:08 +0100 (CET)
Message-ID: <34241.129.240.228.53.1201623428.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:44917 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765987AbYA2QRK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 11:17:10 -0500
Received: from mail-mx6.uio.no ([129.240.10.47])
	by pat.uio.no with esmtp (Exim 4.67)
	(envelope-from <kristrev@ulrik.uio.no>)
	id 1JJt92-0004ua-My
	for netdev@vger.kernel.org; Tue, 29 Jan 2008 17:17:08 +0100
Received: from smtp.uio.no ([129.240.10.9] helo=mail-mx6.uio.no)
	by mail-mx6.uio.no with esmtp (Exim 4.67)
	(envelope-from <kristrev@ulrik.uio.no>)
	id 1JJt92-0006QJ-DK
	for netdev@vger.kernel.org; Tue, 29 Jan 2008 17:17:08 +0100
Received: from mail-web3.uio.no ([129.240.10.20] helo=webmail.uio.no)
	by mail-mx6.uio.no with esmtp (Exim 4.67)
	(envelope-from <kristrev@ulrik.uio.no>)
	id 1JJt92-0006QF-9I
	for netdev@vger.kernel.org; Tue, 29 Jan 2008 17:17:08 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am working on a patch to the TCP-code that, among others, share
fragments between skbs, and have encountered a problem that I'm not sure
if I have solved correctly.

To share a fragment, I copy the skb_frag-struct to the correct place in
the other skbs frags-array, increase the page-counter, skb->data_len,
skb->len, skb->end_seq and gso_segs/gso_size, and calculate a new
checksum.

The problem is the skb->truesize-variable. Currently I do not increase it,
leading to a SKB BUG because truesize is less than (skb->len +
sizeof(struct skb)). When I increase/decrease truesize, both the
wmem_queue and sk_forward_alloc is something else than zero and the socket
leaks memory.

The kernel does not halt and all the data is received correctly in both
cases.

The reason that I currently don't increase/decrease truesize is that, at
least if I have understod the code correctly, truesize says something
about how much memory an skb actually consumes. And since I only copy
existing fragments into it, I don't use any more memory.

Is this correct, or should I increase/decrease truesize as well? Also, is
there a better way to share fragments between skbs?

Thanks in advance for any replies,
Kristian

