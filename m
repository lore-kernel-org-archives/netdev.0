From: John Heffner <johnwheffner@gmail.com>
Subject: Re: TCP: big bursts due to undos resulting from reordering
Date: Thu, 2 Dec 2010 12:55:48 -0500
Message-ID: <AANLkTi=ptmSAAjiwmFyYx3QmcSXz2aZ7vn_Vf8+cLKW3@mail.gmail.com>
References: <4CF7BCF1.7000505@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45538 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757971Ab0LBRzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 12:55:50 -0500
Received: by eye27 with SMTP id 27so4448657eye.19
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 09:55:48 -0800 (PST)
In-Reply-To: <4CF7BCF1.7000505@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do you have some tests showing that the larger busts hurt?  The
problem that occurred, prior to this patch, was that cwnd was not able
to effectively grow under persistent reordering.

You can see my justification for using the reordering threshold in the
archives here: <http://marc.info/?l=linux-netdev&m=120835698002118&w=2>.

Thanks,
  -John


On Thu, Dec 2, 2010 at 10:36 AM, Lennart Schulte
<lennart.schulte@nets.rwth-aachen.de> wrote:
> Hi John, hi Ilpo,
>
> at the moment I look on many TCP plots with reordering. When reordering
> occurs there are some spurious retransmissions which are later undone by
> e.g. DSACKs. This undo results in a very big burst of packets when
> tp->reordering is high, since the function tcp_max_burst() returns
> tp->reordering.
>
> This behavior was introduced because of a bug when using SACK instead of
> Reno. The thread concerning this fix can be found at [1].
>
> Before the patch, which results from this thread, Linux has done a burst
> of 3 packets and then slow started to the undone ssthresh value, which
> is a much better way of handling an undo then it is after the patch.
>
> Also I patched a kernel to use the old max_burst value of 3 again to see
> if it has any effect. Then I set up some virtual nodes and emulated a
> network with netem as it was done in the thread.
> The settings are:
> - RTT 40ms
> - no congestion, application sending rate 20 Mbps
> - forward path: reordering rate 20%, reordering delay 20ms
> - timestamps on
>
> Until now I have not found any evidence that the problem occurs (perhaps
> because I don't get the settings right, since in the thread there is no
> information concerning the settings for reordering and also the ones of
> the sysctls).
>
> My problem is to understand why the patch was necessary and under what
> circumstances SACK has a lower throughput so that it may be possible for
> me to find another way of fixing this without introducing and old bug.
> Since I can't figure it out on my own I hope to get some insights this
> way :)
>
> Thanks,
> Lennart Schulte
>
> [1] http://marc.info/?t=120728958000004&r=2&w=2
>
