From: Jan Glauber <jang@linux.vnet.ibm.com>
Subject: Re: [RFC] qeth: exploit gro for layer 3 driver
Date: Thu, 21 Jan 2010 15:35:27 +0100
Message-ID: <1264084527.5880.45.camel@bender>
References: <20100121123722.GA13815@tuxmaker.boeblingen.de.ibm.com>
	 <20100121.051133.102632014.davem@davemloft.net>
	 <20100121134845.GA28645@tuxmaker.boeblingen.de.ibm.com>
	 <20100121.060354.119388130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: frank.blaschka@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:57053 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab0AUOfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 09:35:46 -0500
In-Reply-To: <20100121.060354.119388130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-01-21 at 06:03 -0800, David Miller wrote:
> From: Blaschka <frank.blaschka@de.ibm.com>
> Date: Thu, 21 Jan 2010 14:48:45 +0100
> 
> > So the qeth driver can not disable qdio IRQs (I guess this is a
> > major reason why not using NAPI) and poll the data.
> 
> Just because you cannot stop the events from coming in
> doesn't mean you can't just queue them up in software
> or similar.

The data is already queued (since qdio stands for queued direct I/O).
Currently qdio gets the interrupt, does some processing and
tells qeth which buffers contain the new data.

So the only question is what needs to be different for NAPI
regarding the event signaling.

--Jan

> The important bits you get are:
> 
> 1) RX ring depletion and packet processing all from software
>    interrupt context
> 
> 2) transparent GRO support, without the generic code having
>    to disclose most of the GRO internals to drivers
> 
> I think it can be done.
> 
> I have a similar issue as your's with the Sun virtualized network
> driver (I can't really stop the hypervisor events from pouring in) on
> sparc64 and I plan to add NAPI support to it.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-s390" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

