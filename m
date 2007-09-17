From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/10 REV5] Implement skb batching and support in
	IPoIB/E1000
Date: Sun, 16 Sep 2007 23:01:43 -0400
Message-ID: <1189998103.4230.76.camel@localhost>
References: <1189988958.4230.55.camel@localhost>
	 <20070916.180232.101592975.davem@davemloft.net>
	 <1189995261.4230.61.camel@localhost>
	 <20070916.192502.123919711.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:24657 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbXIQDBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 23:01:49 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1234841wxd
        for <netdev@vger.kernel.org>; Sun, 16 Sep 2007 20:01:48 -0700 (PDT)
In-Reply-To: <20070916.192502.123919711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-16-09 at 19:25 -0700, David Miller wrote:

> There are tertiary issues I'm personally interested in, for example
> how well this stuff works when we enable software GSO on a non-TSO
> capable card.
> 
> In such a case the GSO segment should be split right before we hit the
> driver and then all the sub-segments of the original GSO frame batched
> in one shot down to the device driver.

I think GSO is still useful on top of this.
In my patches anything with gso gets put into the batch list and shot
down the driver. Ive never considered checking whether the nic is TSO
capable, that may be something worth checking into. The netiron allows
you to shove upto 128 skbs utilizing one tx descriptor, which makes for
interesting possibilities.

> In this way you'll get a large chunk of the benefit of TSO without
> explicit hardware support for the feature.
> 
> There are several cards (some even 10GB) that will benefit immensely
> from this.

indeed - ive always wondered if batching this way would make the NICs
behave differently from the way TSO does.

On a side note: My observation is that with large packets on a very busy
system; bulk transfer type app, one approaches wire speed; with or
without batching, the apps are mostly idling (Ive seen upto 90% idle
time polling at the socket level for write to complete with a really
busy system). This is the case with or without batching. cpu seems a
little better with batching. As the aggregation of the apps gets more
aggressive (achievable by reducing their packet sizes), one can achieve
improved throughput and reduced cpu utilization. This all with UDP; i am
still studying tcp. 
 
cheers,
jamal

