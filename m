From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/4] [NET_SCHED] explict hold dev tx lock
Date: Mon, 08 Oct 2007 09:34:50 -0400
Message-ID: <1191850490.4352.41.camel@localhost>
References: <1190674298.4264.24.camel@localhost>
	 <D5C1322C3E673F459512FB59E0DDC32903A51462@orsmsx414.amr.corp.intel.com>
	 <1190677099.4264.37.camel@localhost>
	 <20071007.215124.85709188.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	mcarlson@broadcom.com, jeff@garzik.org, mchan@broadcom.com,
	general@lists.openfabrics.org, kumarkr@linux.ibm.com,
	tgraf@suug.ch, randy.dunlap@oracle.com, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:6982 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbXJHNfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 09:35:05 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1320982wxd
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2007 06:35:04 -0700 (PDT)
In-Reply-To: <20071007.215124.85709188.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-07-10 at 21:51 -0700, David Miller wrote:

> For these high performance 10Gbit cards it's a load balancing
> function, really, as all of the transmit queues go out to the same
> physical port so you could:
> 
> 1) Load balance on CPU number.
> 2) Load balance on "flow"
> 3) Load balance on destination MAC
> 
> etc. etc. etc.

The brain-block i am having is the parallelization aspect of it.
Whatever scheme it is - it needs to ensure the scheduler works as
expected. For example, if it was a strict prio scheduler i would expect
that whatever goes out is always high priority first and never ever
allow a low prio packet out at any time theres something high prio
needing to go out. If i have the two priorities running on two cpus,
then i cant guarantee that effect.
IOW, i see the scheduler/qdisc level as not being split across parallel
cpus. Do i make any sense?

The rest of my understanding hinges on the above, so let me stop here.

cheers,
jamal

