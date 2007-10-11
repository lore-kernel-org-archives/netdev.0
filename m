From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Thu, 11 Oct 2007 12:22:23 +0530
Message-ID: <OF796924F4.13CE6BB8-ON65257371.002057A5-65257371.0025C19A@in.ibm.com>
References: <20071009.134331.35664207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: andi@firstfloor.org, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, randy.dunlap@oracle.com,
	rdreier@cisco.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP04.au.ibm.com ([202.81.18.173]:37744 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbXJKGvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 02:51:07 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9B6ootI025478
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 16:50:50 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9B6oqGk4870372
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 16:50:52 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9B6oY2H026264
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 16:50:36 +1000
In-Reply-To: <20071009.134331.35664207.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

David Miller wrote on 10/10/2007 02:13:31 AM:

> > Hopefully that new qdisc will just use the TX rings of the hardware
> > directly. They are typically large enough these days. That might avoid
> > some locking in this critical path.
>
> Indeed, I also realized last night that for the default qdiscs
> we do a lot of stupid useless work.  If the queue is a FIFO
> and the device can take packets, we should send it directly
> and not stick it into the qdisc at all.

Since you are talking of how it should be done in the *current* code,
I feel LLTX drivers will not work nicely with this.

Actually I was trying this change a couple of weeks back, but felt
that doin go would result in out of order packets (skbs present in
q which were not sent out for LLTX failure will be sent out only at
next net_tx_action, while other skbs are sent ahead).

One option is to first call qdisc_run() and then process this skb,
but that is ugly (requeue handling).

However I guess this can be done cleanly once LLTX is removed.

Thanks,

- KK

