From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 01 Sep 2009 16:58:15 +0200
Message-ID: <4A9D3687.2020101@gmail.com>
References: <20090901063726.GA5222@ff.dom.local> <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1> <4A9D2DBF.8030200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	davem@linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35364 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754753AbZIAO6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 10:58:22 -0400
In-Reply-To: <4A9D2DBF.8030200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Christoph Lameter wrote:
>> Eric: This occurs with a Broadcom driver (bnx2). There is only one
>> network device up and the IP statistics are correctly incremented.
>=20
> That explains it. The bnx2 driver uses multiple TX queues, but
> tc_dump_qdisc() only dumps the statistics from queue number 0.
>=20
> Not sure whether we should sum them up or dump the statistics
> from each queue (or both). Summing them up avoids userspace
> visible changes when drivers are converted to multiq.

Ok mystery solved, partially at least :)

Hmm, my bnx2 still displays correct info here (BCM5708S) ; so maybe Chr=
istoph has a
real multiqueue NIC adapter ? I thought he mentioned a mono queue NIC e=
arlier.

Dumping stats for each queue would be better for admin point of view IM=
HO
(restricted to real_num_tx_queues I guess, since bnx2 allocates 8 queue=
s per device.


