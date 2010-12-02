From: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Subject: TCP: big bursts due to undos resulting from reordering
Date: Thu, 2 Dec 2010 16:36:17 +0100
Message-ID: <4CF7BCF1.7000505@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	John Heffner <johnwheffner@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-i4.nets.RWTH-Aachen.DE ([137.226.12.21]:41584 "EHLO
	MAIL-i4.nets.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753581Ab0LBPma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 10:42:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John, hi Ilpo,

at the moment I look on many TCP plots with reordering. When reordering
occurs there are some spurious retransmissions which are later undone by
e.g. DSACKs. This undo results in a very big burst of packets when
tp->reordering is high, since the function tcp_max_burst() returns
tp->reordering.

This behavior was introduced because of a bug when using SACK instead of
Reno. The thread concerning this fix can be found at [1].

Before the patch, which results from this thread, Linux has done a burst
of 3 packets and then slow started to the undone ssthresh value, which
is a much better way of handling an undo then it is after the patch.

Also I patched a kernel to use the old max_burst value of 3 again to see
if it has any effect. Then I set up some virtual nodes and emulated a
network with netem as it was done in the thread.
The settings are:
- RTT 40ms
- no congestion, application sending rate 20 Mbps
- forward path: reordering rate 20%, reordering delay 20ms
- timestamps on

Until now I have not found any evidence that the problem occurs (perhaps
because I don't get the settings right, since in the thread there is no
information concerning the settings for reordering and also the ones of
the sysctls).

My problem is to understand why the patch was necessary and under what
circumstances SACK has a lower throughput so that it may be possible for
me to find another way of fixing this without introducing and old bug.
Since I can't figure it out on my own I hope to get some insights this
way :)

Thanks,
Lennart Schulte

[1] http://marc.info/?t=120728958000004&r=2&w=2
