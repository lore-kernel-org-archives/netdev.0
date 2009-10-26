From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: performance regression in virtio-net in 2.6.32-rc4
Date: Mon, 26 Oct 2009 20:48:35 +0200
Message-ID: <20091026184835.GB26473@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22801 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753934AbZJZSvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 14:51:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!
I noticed a performance regression in virtio net: going from
2.6.31 to 2.6.32-rc4 I see this, for guest to host communication:

[mst@tuck ~]$ ssh robin sh streamtest1
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 11.0.0.3
(11.0.0.3) port 0 AF_INET : demo
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.20    7806.48


[mst@tuck ~]$ ssh robin sh streamtest1
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 11.0.0.3
(11.0.0.3) port 0 AF_INET : demo
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    6814.60


Note: I had to revert 48925e372f04f5e35fec6269127c62b2c71ab794,
and I applied a patch
	virtio-pci: fix per-vq MSI-X request logic
which fixes a bug introduced by f68d24082e22ccee3077d11aeb6dc5354f0ca7f1.

Any tips on debugging this?

-- 
MST
