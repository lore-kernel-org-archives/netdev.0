From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 1 Sep 2009 14:29:12 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909011427210.16313@V090114053VZO-1>
References: <20090901063726.GA5222@ff.dom.local> <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1> <4A9D2DBF.8030200@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	davem@linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:46685 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754753AbZIAObF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 10:31:05 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C4F1682C4DC
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 10:32:42 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id J731h2DjVQxc for <netdev@vger.kernel.org>;
	Tue,  1 Sep 2009 10:32:42 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9B4D482C3B3
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 10:31:24 -0400 (EDT)
In-Reply-To: <4A9D2DBF.8030200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Sep 2009, Patrick McHardy wrote:

> Christoph Lameter wrote:
> > Eric: This occurs with a Broadcom driver (bnx2). There is only one
> > network device up and the IP statistics are correctly incremented.
>
> That explains it. The bnx2 driver uses multiple TX queues, but
> tc_dump_qdisc() only dumps the statistics from queue number 0.
>
> Not sure whether we should sum them up or dump the statistics
> from each queue (or both). Summing them up avoids userspace
> visible changes when drivers are converted to multiq.

Well I have almost finished a /proc/net/qdisc_stats that shows *all*
qdisc queues. Did this primarily for debugging since I do not know too
much about the netlink stuff.


