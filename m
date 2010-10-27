From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC PATCH 0/1] vhost: Reduce TX used buffer signal for performance
Date: Wed, 27 Oct 2010 14:00:57 -0700
Message-ID: <1288213257.17571.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "mst@redhat.com" <mst@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch will change vhost TX used buffer guest signaling from one by
one to 3/4 ring size. I have tried different size, like 4, 16, 1/4 size,
1/2 size, and found that the large size is best for message size between
256 - 4K with netperf TCP_STREAM test, so 3/4 of the ring size is picked
up for signaling. 

Tested both UDP and TCP performance with guest 2vcpu. The 60 secs
netperf run shows that guest to host performance for TCP.

TCP_STREAM

Message size	Guest CPU(%)	BW (Mb/s)
		before:after	before:after

256		57.84:58.42	1678.47:1908.75
512		68.68:60.21	1844.18:3387.33
1024		68.01:58.70	1945.14:3384.72
2048		65.36:54.25	2342.45:3799.31
4096		63.25:54.62	3307.11:4451.78
8192		59.57:57.89	6038.64:6694.04

UDP_STREAM
1024		49.64:26.69	1161.0:1687.6
2048		49.88:29.25	2326.8:2850.9
4096		49.59:29.15	3871.1:4880.3
8192		46.09:32.66	6822.9:7825.1
16K		42.90:34.96	11347.1:11767.4

For large message size, 60 secs run remains almost the same. I guess the
signal might not play a big role in large message transmission.

Shirley
