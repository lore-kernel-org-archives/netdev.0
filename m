From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/10 REV5] Implement skb batching and support in
	IPoIB/E1000
Date: Mon, 17 Sep 2007 08:51:40 -0400
Message-ID: <1190033500.4230.102.camel@localhost>
References: <1189995261.4230.61.camel@localhost>
	 <20070916.192502.123919711.davem@davemloft.net>
	 <1189998103.4230.76.camel@localhost>
	 <20070916.201318.71091570.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:53483 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357AbXIQMvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 08:51:46 -0400
Received: by an-out-0708.google.com with SMTP id d31so219994and
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 05:51:45 -0700 (PDT)
In-Reply-To: <20070916.201318.71091570.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-16-09 at 20:13 -0700, David Miller wrote:

> What Herbert and I want to do is basically turn on TSO for
> devices that can't do it in hardware, and rely upon the GSO
> framework to do the segmenting in software right before we
> hit the device.

Sensible. 

> This only makes sense for devices which can 1) scatter-gather
> and 2) checksum on transmit.  

If you have knowledge there are enough descriptors in the driver to
cover all skbs you are passing, do you need to have #1? 
Note i dont touch fragments, i am assuming the driver is smart enough to
handle them otherwise it wont advertise it can handle scatter-gather

> Otherwise we make too many copies and/or passes over the data.

I didnt understand this last bit - you are still going to go over the
list regardless of whether you call ->hard_start_xmit() once or
multiple times over the same list, no? In the later case i am assuming
a trimmed down ->hard_start_xmit()

> UDP is too easy a test case in fact :-)

I learnt a lot about the behavior out of doing udp (and before that with
pktgen); theres a lot of driver habits that may need to be tuned before
batching becomes really effective - which is easier to see with udp than
with tcp.

cheers,
jamal

