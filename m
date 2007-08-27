From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in
	IPoIB
Date: Mon, 27 Aug 2007 19:23:39 -0400
Message-ID: <1188257019.4250.55.camel@localhost>
References: <46CF7B13.3020701@psc.edu>
	 <20070826044134.eabd18cf.billfink@mindspring.com>
	 <46D229AA.6020900@psc.edu>  <20070826.190420.41652839.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, billfink@mindspring.com, rick.jones2@hp.com,
	krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	rdreier@cisco.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.177]:7961 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbXH0XYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 19:24:04 -0400
Received: by el-out-1112.google.com with SMTP id j27so370370elf
        for <netdev@vger.kernel.org>; Mon, 27 Aug 2007 16:24:03 -0700 (PDT)
In-Reply-To: <20070826.190420.41652839.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-26-08 at 19:04 -0700, David Miller wrote:

> The transfer is much better behaved if we ACK every two full sized
> frames we copy into the receiver, and therefore don't stretch ACK, but
> at the cost of cpu utilization.

The rx coalescing in theory should help by accumulating more ACKs on the
rx side of the sender. But it doesnt seem to do that i.e For the 9K MTU,
you are better off to turn off the coalescing if you want higher
numbers. Also some of the TOE vendors (chelsio?) claim to have fixed
this by reducing bursts on outgoing packets.
 
Bill:
who suggested (as per your email) the 75usec value and what was it based
on measurement-wise? 
BTW, thanks for the finding the energy to run those tests and a very
refreshing perspective. I dont mean to add more work, but i had some
queries;
On your earlier tests, i think that Reno showed some significant
differences on the lower MTU case over BIC. I wonder if this is
consistent? 
A side note: Although the experimentation reduces the variables (eg
tying all to CPU0), it would be more exciting to see multi-cpu and
multi-flow sender effect (which IMO is more real world). 
Last note: you need a newer netstat.

> These effects are particularly pronounced on systems where the
> bus bandwidth is also one of the limiting factors.

Can you elucidate this a little more Dave? Did you mean memory
bandwidth? 

cheers,
jamal

