From: Patrick McHardy <kaber@trash.net>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 01 Sep 2009 16:20:47 +0200
Message-ID: <4A9D2DBF.8030200@trash.net>
References: <20090901063726.GA5222@ff.dom.local> <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	davem@linux-foundation.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55389 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754766AbZIAOUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 10:20:51 -0400
In-Reply-To: <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> Eric: This occurs with a Broadcom driver (bnx2). There is only one
> network device up and the IP statistics are correctly incremented.

That explains it. The bnx2 driver uses multiple TX queues, but
tc_dump_qdisc() only dumps the statistics from queue number 0.

Not sure whether we should sum them up or dump the statistics
from each queue (or both). Summing them up avoids userspace
visible changes when drivers are converted to multiq.
