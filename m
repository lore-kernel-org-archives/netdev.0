From: Bill Fink <billfink@mindspring.com>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 10 Oct 2007 12:02:15 -0400
Message-ID: <20071010120215.7ec19323.billfink@mindspring.com>
References: <20071009135340.33e5922c@freepuppy.rosehill>
	<20071009.142235.74385364.davem@davemloft.net>
	<1191967006.5324.14.camel@localhost>
	<20071009.170435.43504422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, shemminger@linux-foundation.org,
	andi@firstfloor.org, jeff@garzik.org, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:45353 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756015AbXJJQD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 12:03:56 -0400
In-Reply-To: <20071009.170435.43504422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 09 Oct 2007, David Miller wrote:

> From: jamal <hadi@cyberus.ca>
> Date: Tue, 09 Oct 2007 17:56:46 -0400
> 
> > if the h/ware queues are full because of link pressure etc, you drop. We
> > drop today when the s/ware queues are full. The driver txmit lock takes
> > place of the qdisc queue lock etc. I am assuming there is still need for
> > that locking. The filter/classification scheme still works as is and
> > select classes which map to rings. tc still works as is etc.
> 
> I understand your suggestion.
> 
> We have to keep in mind, however, that the sw queue right now is 1000
> packets.  I heavily discourage any driver author to try and use any
> single TX queue of that size.  Which means that just dropping on back
> pressure might not work so well.
> 
> Or it might be perfect and signal TCP to backoff, who knows! :-)

I can't remember the details anymore, but for 10-GigE, I have encountered
cases where I was able to significantly increase TCP performance by
increasing the txqueuelen to 10000, which is the setting I now use for
any 10-GigE testing.

						-Bill
