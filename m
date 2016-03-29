From: Guus Sliepen <guus@tinc-vpn.org>
Subject: Best way to reduce system call overhead for tun device I/O?
Date: Wed, 30 Mar 2016 00:40:43 +0200
Message-ID: <20160329224043.GY3784@sliepen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arianus.sliepen.org ([92.243.30.131]:36627 "EHLO
	arianus.sliepen.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbcC2WuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 18:50:14 -0400
Received: from sliepen.org (unknown [10.1.1.1])
	by arianus.sliepen.org (Postfix) with ESMTP id 59A7A264FE
	for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 00:40:43 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by sliepen.org (Postfix) with ESMTP id 1B4C2220425
	for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 00:40:43 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to reduce system call overhead when reading/writing to/from a
tun device in userspace. For sockets, one can use sendmmsg()/recvmmsg(),
but a tun fd is not a socket fd, so this doesn't work. I'm see several
options to allow userspace to read/write multiple packets with one
syscall:

- Implement a TX/RX ring buffer that is mmap()ed, like with AF_PACKET
  sockets.

- Implement a ioctl() to emulate sendmmsg()/recvmmsg().

- Add a flag that can be set using TUNSETIFF that makes regular
  read()/write() calls handle multiple packets in one go.

- Expose a socket fd to userspace, so regular sendmmsg()/recvmmsg() can
  be used. There is tun_get_socket() which is used internally in the
  kernel, but this is not exposed to userspace, and doesn't look trivial
  to do either.

What would be the right way to do this?

-- 
Met vriendelijke groet / with kind regards,
     Guus Sliepen <guus@tinc-vpn.org>
