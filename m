From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in
 IPoIB
Date: Thu, 23 Aug 2007 15:30:47 -0700 (PDT)
Message-ID: <20070823.153047.99173582.davem@davemloft.net>
References: <46CC6DD1.5020105@hp.com>
	<20070822.132145.90824527.davem@davemloft.net>
	<1187906650.4279.16.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	Robert.Olsson@data.slu.se, shemminger@linux-foundation.org,
	sri@us.ibm.com, tgraf@suug.ch, xma@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40999
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933452AbXHWWav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 18:30:51 -0400
In-Reply-To: <1187906650.4279.16.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 23 Aug 2007 18:04:10 -0400

> Possibly a bug - but you really should turn off TSO if you are doing
> huge interactive transactions (which is fair because there is a clear
> demarcation).

I don't see how this can matter.

TSO only ever does anything if you accumulate more than one MSS
worth of data.

And when that does happen, all it does is take whats in the send queue
and send as much as possible at once.  The packets are already built
in big chunks, so there is no extra work to do.

The card is going to send the things back to back and as fast as
in the non-TSO case as well.

It doesn't change application scheduling, and it absolutely does not
penalize small sends by the application unless we have a bug
somewhere.

So I see no reason to disable TSO for any reason other than hardware
implementation deficiencies.  And for the drivers I am familiar with
they do make smart default TSO enabling decisions based upon how well
the chip does TSO.

