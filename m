From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3_close question
Date: Thu, 9 Nov 2006 09:35:11 -0800
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FCD0@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <5cac192f0611090922x7b6f8369of5bf294e9768800d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:20489 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1424169AbWKIRfZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 12:35:25 -0500
Content-class: urn:content-classes:message
In-Reply-To: <5cac192f0611090922x7b6f8369of5bf294e9768800d@mail.gmail.com>
To: "Eric Lemoine" <eric.lemoine@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Lemoine wrote:

> > On 11/9/06, Michael Chan <mchan@broadcom.com> wrote:
> > > So it is not possible for tg3_poll() -> tg3_tx() to run any more
> > > after tg3_close() is called.
> >
> > But, while tg3_close() starts executing, an interrupt may 
> > come in and
> > schedule polling (set  __LINK_STATE_RX_SCHED). So tg3_poll() ->
> > tg3_tx() may well occur.
> 
> Actually I don't understand the purpose of having dev_close() wait for
> __LINK_STATE_RX_SCHED to be cleared. An interrupt may arrive at any
> time after it's cleared, and reset __LINK_STATE_RX_SCHED. Can someone
> explain please?
> 

If netif_running() is cleared, netif_rx_schedule() will not schedule
the ->poll().  So even if tg3 gets an interrupt after close,
tg3_poll() will not be scheduled.

