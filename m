From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 5/7] dccp tfrc: Increase number of RTT samples
Date: Wed, 30 Jul 2008 13:02:43 +0100
Message-ID: <20080730120243.GA4961@gerrit.erg.abdn.ac.uk>
References: <1217325952-12337-1-git-send-email-gerrit@erg.abdn.ac.uk> <1217325952-12337-2-git-send-email-gerrit@erg.abdn.ac.uk> <1217325952-12337-3-git-send-email-gerrit@erg.abdn.ac.uk> <1217325952-12337-4-git-send-email-gerrit@erg.abdn.ac.uk> <1217325952-12337-5-git-send-email-gerrit@erg.abdn.ac.uk> <1217325952-12337-6-git-send-email-gerrit@erg.abdn.ac.uk> <5640c7e00807291539o4a116aebta34dea1dc8eb3081@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46779 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753927AbYG3MC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 08:02:57 -0400
Content-Disposition: inline
In-Reply-To: <5640c7e00807291539o4a116aebta34dea1dc8eb3081@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > The effectiveness of using suboptimal samples (with a delta between 1 and 4) was
| > confirmed by instrumenting the algorithm with counters. The results of two 20
| > second test runs were:
| >  * With the old algorithm and a total of 38442 function calls, only 394 of these
| >   calls resulted in usable RTT samples (about 1%), 378 out of these were
| >   "perfect" samples, and 28013 (unused) samples had a delta of 1..3.
| >  * With the new algorithm and a total of 37057 function calls, 1702 usable RTT
| >   samples were retrieved (about 4.6%), 5 out of these were "perfect" samples.
| > This means an almost five-fold increase in the number of samples.
| >
| 
| Great work. This should make a real improvement.
| 
Unfortunately it does not change some of the conceptual problems. When
the sender is sending at a rate of less than one packet per RTT then it
can happen that there are no usable RTT samples for a long while.

MP3 streaming is an example, and there are other audio/voice streaming
formats which also do not need to send more than one packet per RTT.

In one case of MP3 streaming there was not a single usable RTT estimate
over the course of almost 1-2 hours (found via printk to syslot).
What happens if meanwhile the link properties change?

I am not at all happy with this algorithm, it is probably as good as it
can get, but it won't help if the sending rate is low.
