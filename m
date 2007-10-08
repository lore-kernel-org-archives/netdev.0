From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCHES] TX batching
Date: Mon, 08 Oct 2007 10:05:20 -0400
Message-ID: <1191852320.4352.73.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	 <20070916.161748.48388692.davem@davemloft.net>
	 <1189988958.4230.55.camel@localhost> <1190569987.4256.52.camel@localhost>
	 <1191782093.4394.60.camel@localhost>  <20071008125125.GA31456@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:25043 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbXJHOFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 10:05:44 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1329391wxd
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2007 07:05:43 -0700 (PDT)
In-Reply-To: <20071008125125.GA31456@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-10 at 16:51 +0400, Evgeniy Polyakov wrote:

> it looks like you and Krishna use the same requeueing methods - get one
> from qdisk, queue it into blist, get next from qdisk, queue it,
> eventually start transmit, where you dequeue it one-by-one and send (or
> prepare and commit). This is not the 100% optimal approach, but if you
> proved it does not hurt usual network processing, it is ok.

There are probably other bottlenecks that hide the need to optimize
further.

> Number of comments dusted to very small - that's a sign, but I'm a bit
> lost - did you and Krishna create the competing approaches, or they can
> co-exist together, in the former case I doubt you can push, until all
> problematic places are resolved, in the latter case, this is probably
> ready.

Thanks. I would like to make one more cleanup and get rid of the
temporary pkt list in qdisc restart; now that i have defered the skb
pre-format interface it is unnecessary.  I have a day off today, so i
will make changes, re-run tests and post again.

I dont see something from Krishna's approach that i can take and reuse.
This maybe because my old approaches have evolved from the same path.
There is a long list but as a sample: i used to do a lot more work while
holding the queue lock which i have now moved post queue lock; i dont
have any speacial interfaces/tricks just for batching, i provide hints
to the core of how much the driver can take etc etc. I have offered
Krishna co-authorship if he makes the IPOIB driver to work on my
patches, that offer still stands if he chooses to take it. 

cheers,
jamal

