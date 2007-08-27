From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Mon, 27 Aug 2007 11:47:01 +0200
Message-ID: <200708271147.01890.ossthema@de.ibm.com>
References: <46CF127D.1090609@katalix.com> <46D1D634.7060007@katalix.com> <20070826.185815.93042514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, shemminger@linux-foundation.org,
	akepner@sgi.com, netdev@vger.kernel.org, raisch@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, meder@de.ibm.com, tklein@de.ibm.com,
	stefan.roscher@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:35674 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753113AbXH0JrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 05:47:16 -0400
In-Reply-To: <20070826.185815.93042514.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 27 August 2007 03:58, David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Sun, 26 Aug 2007 20:36:20 +0100
> 
> > David Miller wrote:
> > > From: James Chapman <jchapman@katalix.com>
> > > Date: Fri, 24 Aug 2007 18:16:45 +0100
> > > 
> > >> Does hardware interrupt mitigation really interact well with NAPI?
> > > 
> > > It interacts quite excellently.
> > 
> > If NAPI disables interrupts and keeps them disabled while there are more 
> > packets arriving or more transmits being completed, why do hardware 
> > interrupt mitigation / coalescing features of the network silicon help?
> 
> Because if your packet rate is low enough such that the cpu can
> process the interrupt fast enough and thus only one packet gets
> processed per NAPI poll, the cost of going into and out of NAPI mode
> dominates the packet processing costs.

As far as I understand your argumentation, NAPI is supposed to work well only
for HW with coalescing features (concerning dropping the interrupt rate).
NAPI itself does not provide a reliable functionality to reduce the
number of interrupts, especially not for systems with only 1 NIC. 
NAPI will only wait for some time when the budget is exceeded
and the softIRQs don't call net_rx_action again. This seems to be the case
after 10 rounds. That means NAPI really waits after 300 x 10 packets 
have been processed in a row (worst case).

As a matter of fact there is HW that does not have this feature. There seems
to be HW which does not work well with plain NAPI.
This HW performs well if the operation system supports HP timers 
(and when they are used either in the device driver or polling engine).

So the question is simply: Do we want drivers that need (benefit from)
a timer based polling support to implement their own timers each, 
or should there be a generic support? 

Thanks,
Jan-Bernd

