From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Weird TCP SACK problem. in Linux...
Date: Fri, 21 Jul 2006 03:23:04 +0400
Message-ID: <20060720232304.GA21573@ms2.inr.ac.ru>
References: <44BD38B1.1080807@kom.aau.dk> <20060719132719.GA22143@ms2.inr.ac.ru> <44BE498F.9070001@kom.aau.dk> <20060719154934.GA29877@ms2.inr.ac.ru> <44BE5E89.1020002@kom.aau.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:34786 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1030407AbWGTXXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 19:23:16 -0400
To: Oumer Teyeb <oumer@kom.aau.dk>
Content-Disposition: inline
In-Reply-To: <44BE5E89.1020002@kom.aau.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Hmmm... I dont understand this....so if reording can be detected, (i.e 
> we use timestamps, DSACK), the dupthreshold is increased

Yes.

> implementation that might lead to increase in the number of 
> retransmissions, but leads to improvment in download time

Hmm... I thought and still do not know.


> couldnt figure it out,....also is there anywhere where the reordering 
> response of tcp linux described? (it seem dupthreshold is dynamically 
> adjusted based on the reordering history... but I was not able to find 
> out how...)...

That's comment from tcp_input:

 * Reordering detection.
 * --------------------
 * Reordering metric is maximal distance, which a packet can be displaced
 * in packet stream. With SACKs we can estimate it:
 *
 * 1. SACK fills old hole and the corresponding segment was not
 *    ever retransmitted -> reordering. Alas, we cannot use it
 *    when segment was retransmitted.
 * 2. The last flaw is solved with D-SACK. D-SACK arrives
 *    for retransmitted and already SACKed segment -> reordering..


Alexey

