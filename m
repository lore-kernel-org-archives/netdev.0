From: Bill Fink <billfink@mindspring.com>
Subject: Re: setsockopt()
Date: Thu, 10 Jul 2008 20:50:45 -0400
Message-ID: <20080710205045.8b8a0eee.billfink@mindspring.com>
References: <48725DFE.6000504@citi.umich.edu>
	<20080707142408.43aa2a2e@extreme>
	<48728B09.1050801@citi.umich.edu>
	<20080707.144912.76654646.davem@davemloft.net>
	<20080708045443.GA7726@2ka.mipt.ru>
	<20080708020235.388a7bd5.billfink@mindspring.com>
	<adar6a4x510.fsf@cisco.com>
	<20080708144817.3c364962.billfink@mindspring.com>
	<ada63rfrkrs.fsf@cisco.com>
	<20080709183432.GB5383@2ka.mipt.ru>
	<20080709225035.a4d39cb5.billfink@mindspring.com>
	<48764629.6090209@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Roland Dreier <rdreier@cisco.com>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu,
	bfields@fieldses.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:59675
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754661AbYGKAvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 20:51:03 -0400
In-Reply-To: <48764629.6090209@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Jul 2008, Rick Jones wrote:

> > In my own network benchmarking experience, I've generally gotten the
> > best performance results when the nuttcp application and the NIC
> > interrupts are on the same CPU, which I understood was because of
> > cache effects.
> 
> Interestingly enough I have a slightly different experience:
> 
> *) single-transaction, single-stream TCP_RR - best when app and NIC use 
> same core
> 
> *) bulk transfer - either TCP_STREAM or aggregate TCP_RR:
>    a) enough CPU on one core to reach max tput, best when same core
>    b) not enough, tput max when app and NIC on separate cores, 
> preferably cores sharing some cache
> 
> That is in the context of either maximizing throughput or minimizing 
> latency.  If the context is most efficient transfer, then in all cases 
> my experience thusfar agrees with yours.

Yes, I was talking about single stream bulk data transfers, where the
CPU was not a limiting factor (just barely when doing full 10-GigE
line rate transfers with 9000-byte jumbo frames).

On multiple stream tests there can be a benefit to spreading the load
across multiple cores.

						-Bill
