From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Userspace network stack release.
Date: Sat, 14 Jun 2008 18:08:12 +0400
Message-ID: <20080614140812.GB9692@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50277 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765AbYFNOIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jun 2008 10:08:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

This new release of the userspace only brings a bug fix found by
Salvatore Del Popolo (delpopolo_dit.unitn.it) in TCP implementation,
when system checked sending window and determined, that packet was not
allowed to be sent and nevertheless tried to do so in some cases.

Userspace network stack is a very fast (if working on top of
netchannels, also supported packet socket) and very small network stack
(TCP/UDP/IP/ethernet) implemeneted entirely in userspace. Because of it
lives near the very the end of the peer (i.e. very close or even
embedded into application), it allows much faster processing of some
workloads, namely small packet sending and receiving, where it
outperforms vanilla Linux TCP/IP stack upto 3 times in performance and 4
times CPU usage (sending and receiving vary).

Sending:
128 bytes writing:
  * netchannels: 27-28 MB/sec, 20-30 % CPU usage
  * sockets: 7-8 MB/sec, 80-90 % CPU usage
4096 bytes writing:
  * netchannels: 27-28 MB/sec, 20-30 % CPU usage
  * sockets: 30-31 MB/sec, 30-40 % CPU usage

Receiving:
128 bytes reading:
  * netchannels: 70-71 MB/sec, 80-90 % CPU usage
  * sockets: 24-25 MB/sec, 80-90 % CPU usage
 4096 bytes reading:
  * netchannels: 73-74 MB/sec, 80-90 % CPU usage
  * sockets: 79-80 MB/sec, 80-90 % CPU usage

That's rather old numbers though.
It is not about problems in the Linux stack, but overhead of syscalls,
which are in turn results of too separate data sending and reply
processing in the existing model.

Userspace network stack homepage:
http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack

Netchannels homepage:
http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel

-- 
	Evgeniy Polyakov
