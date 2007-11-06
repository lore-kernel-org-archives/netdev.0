From: Andi Kleen <andi@firstfloor.org>
Subject: Re: localhost network processing on smp machines
Date: Tue, 06 Nov 2007 11:53:07 +0100
Message-ID: <p73tznz1w8c.fsf@bingen.suse.de>
References: <c565abbb0711051248g76fbd695w2dbb13f0e014087d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Matthew Faulkner" <matthew.faulkner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:40466 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755367AbXKFKxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 05:53:09 -0500
In-Reply-To: <c565abbb0711051248g76fbd695w2dbb13f0e014087d@mail.gmail.com> (Matthew Faulkner's message of "Mon\, 5 Nov 2007 20\:48\:39 +0000")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Matthew Faulkner" <matthew.faulkner@gmail.com> writes:

> I'm probably being stupid and very confused here. Appologies if it is
> a stupid question.
>
> For a particular test I assign a client to core 1 and a server to core
> 0. My first assumption was all the sending side kernel TCP/IP
> processing will be done on core 1 and all the receiving side
> processing on core 0. However, having looked at the linux TCP/IP code,
> more specifically the loopback device code, when the loopbacks
> dev_queue_xmit function gets called it simply passes the skb to the
> netif_rx function. Therefore my question is thus, when i assign the
> sending / receiving side to different cores is the actual TCP/IP
> processing done the assigned sending / receiving cores ? or is TCP/IP
> processing done on the sending side only until a certain point? 
> it simply a single core that does all the TCP/IP processing. If it's
> the first two and you have any idea, could you point me where in the
> kernel the cores the processing swap over.

You need to define what you mean with TCP/IP processing. It has lots
of little sub-actions.  For the loopback case some will always run on
the sender side (IP, socket demultiplex, some will sometimes run on
either depending on workload (using TCP prequeue and depending on the
tcp_latency setting and how quickly the receiver schedules), and some
always on the receiver side (recvmsg user processing)

-Andi
