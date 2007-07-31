From: "Siddharth Taneja" <siddharth.taneja@gmail.com>
Subject: Scatter gather and TCP MD5
Date: Tue, 31 Jul 2007 03:17:25 -0700
Message-ID: <526ad3230707310317p537d6cfdj2820a0ffe77c059b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:2997 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757631AbXGaKR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 06:17:27 -0400
Received: by py-out-1112.google.com with SMTP id d32so3219199pye
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 03:17:26 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am using a vanilla 2.6.22.1 kernel and I see the same kind of
problem as had been mentioned some time back on this list

http://lkml.org/lkml/2007/5/22/45

The issue is essentially that with the MD5 option enabled for the
specific TCP connection, the SYN and SYN-ACKS are passed ok and the
connection establishes fine, but the other end (a cisco router)
complains about incorrect MD5 signatures on any other message that is
sent after this.

Setting the scatter-gather offloading option to off on the NIC seems to
correct this problem. Recently I had seen a checkin (as a response to
the problem mentioned in the above link) where the TSO option was
turned off to make MD5 work (my kernel has that fix). Is a similar
solution needed here too?

This is the information about my system:
> uname -a
Linux stdalone 2.6.22.1 #1 SMP Mon Jul 23 20:15:21 PDT 2007 i686 i686
i386 GNU/Linux

> ethtool -i eth0
driver: e1000
version: 7.3.20-k2
firmware-version: N/A
bus-info: 0000:01:0a.0

> ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: off
tcp segmentation offload: off

Thanks for your help.

Siddharth

PS: I would like to be CC'ed on the reply to this email. Thanks.
