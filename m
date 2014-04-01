From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: cache coherency problem, why not happening ?
Date: Tue, 1 Apr 2014 09:49:53 +0530
Message-ID: <CAGZFCEFDM109559QWXMSoy7Cru5-2MQt-4FX_tk6uK1-u7M-7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>,
	Netfilter mailing list <netfilter@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:53276 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbaDAETy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 00:19:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I  could see     spin lock   (&sk->sk_receive_queue.lock)   is
acquired  before queing  sk_buff . This is done in interrupt context (
called from bottom half,
http://lxr.linux.no/#linux+v3.13.5/net/packet/af_packet.c#L1818 ).
userspace can receive the packet using  system call and system call
will acquire the same lock
( http://lxr.linux.no/#linux+v3.13.5/net/core/datagram.c#L191 ).


Suppose in smp machine,  if  bottom half is executed by  cpu #1  and
the  userspace process is pinned to cpu #2.  How can the  spin lock
acuquired info ( lock value ) will be reflected   to cpu #2 ( if cpu
#2 has already acquired and released the lock value and the lock value
is  stored in a cpu #2 data cache. so if cpu #1 acquire it , cpu#2
will read the cache value which says it is free). I could see that
spin_lock_t is not a volatile value also.


Thanks,
Ratheesh
