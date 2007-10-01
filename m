From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 01 Oct 2007 09:30:40 -0400
Message-ID: <1191245440.4378.12.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	 <20070916.161748.48388692.davem@davemloft.net>
	 <1189988958.4230.55.camel@localhost> <1190569987.4256.52.camel@localhost>
	 <1190570205.4256.56.camel@localhost> <1190570317.4256.59.camel@localhost>
	 <1190570409.4256.62.camel@localhost> <1191178346.6165.29.camel@localhost>
	 <20071001001135.75d2b984.billfink@mindspring.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:1589 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628AbXJANar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 09:30:47 -0400
Received: by wx-out-0506.google.com with SMTP id h31so3278388wxd
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2007 06:30:46 -0700 (PDT)
In-Reply-To: <20071001001135.75d2b984.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-01-10 at 00:11 -0400, Bill Fink wrote:

> Have you done performance comparisons for the case of using 9000-byte
> jumbo frames?

I havent, but will try if any of the gige cards i have support it.

As a side note: I have not seen any useful gains or losses as the packet
size approaches even 1500B MTU. For example, post about 256B neither the
batching nor the non-batching give much difference in either throughput
or cpu use. Below 256B, theres a noticeable gain for batching.
Note, in the cases of my tests all 4 CPUs are in full-throttle UDP and
so the occupancy of both the qdisc queue(s) and ethernet ring is
constantly high. For example at 512B, the app is 80% idle on all 4 CPUs
and we are hitting in the range of wire speed. We are at 90% idle at
1024B. This is the case with or without batching.  So my suspicion is
that with that trend a 9000B packet will just follow the same pattern.


cheers,
jamal

