From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: What's the benefit of large Rx rings?
Date: Mon, 23 Nov 2015 17:27:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBDA892@AcuExch.aculab.com>
References: <CO2PR11MB008832EB5323120812FFDAF597180@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Yuval Mintz' <Yuval.Mintz@qlogic.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:63061 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171AbbKWR3v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 12:29:51 -0500
In-Reply-To: <CO2PR11MB008832EB5323120812FFDAF597180@CO2PR11MB0088.namprd11.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz
> Sent: 22 November 2015 20:19
> This might be a dumb question, but I recently touched this
> and felt like I'm missing something basic -
> 
> NAPI is being scheduled from soft-interrupt contex, and it
> has a ~strict quota for handling Rx packets [even though we're
> allowing practically unlimited handling of Tx completions].
> Given these facts, what's the benefit of having arbitrary large
> Rx buffer rings? Assuming quota is 64, I would have expected
> that having more than twice or thrice as many buffers could not
> help in real traffic scenarios - in any given time-unit
> [the time between 2 NAPI runs which should be relatively
> constant] CPU can't handle more than the quota; If HW is
> generating more packets on a regular basis the buffers are bound
> to get exhausted, no matter how many there are.

What you don't want is guaranteed packet loss for common scenarios.

The worst one we I've seen was not having enough buffers for a
single NFS 8k UDP datagram (was a long time ago).

But a 64k send using hardware TSO will most likely give you
about 40 receive frames back to back, unless you can keep up
with line speed (unlikely at high speeds on a slow cpu) you
may need several times that many buffers to handle rx data
on multiple connections.
At some point data will get discarded, but usually the delays
in sending acks will slow down the receive data.

In reality it is all a trade off between a lot of rx buffers
and recovering from rx discards.

	David
