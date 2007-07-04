From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [WIP][PATCHES] Network xmit batching - tg3 support
Date: Wed, 4 Jul 2007 09:49:32 +0530
Message-ID: <OF95AE6EF1.D13A78A8-ON6525730E.0016D384-6525730E.0017C2E4@in.ibm.com>
References: <1183469180.5159.89.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Gagan Arneja <gaagaan@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Sridhar Samudrala <sri@us.ibm.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:46133 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbXGDESn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 00:18:43 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l644eX02041066
	for <netdev@vger.kernel.org>; Wed, 4 Jul 2007 14:40:38 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l644Ld2X065080
	for <netdev@vger.kernel.org>; Wed, 4 Jul 2007 14:21:40 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l644I6B2021355
	for <netdev@vger.kernel.org>; Wed, 4 Jul 2007 14:18:07 +1000
In-Reply-To: <1183469180.5159.89.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jamal,

J Hadi Salim <j.hadi123@gmail.com> wrote on 07/03/2007 06:56:20 PM:

> On Mon, 2007-02-07 at 17:21 -0700, Michael Chan wrote:
>
> [Matt, please include the count in the fix per previous email]
> long answer:
> My goal with storing these values and computing them was to do certain
> things that dont require holding the netif_tx_lock within a batch as
> well. Evaluating the packet metadata and formating the packet to be
> ready for stashing into DMA was one thing i could do outside of holding
> the lock easily - and running that in loop of 100 packets amortizes the
> instruction cache and allows me (when i get to it) to hold the lock for
> a lot less computation.

Do you see any contention for tx_lock which can justify having a prep
handler? As I understood, no other CPU can be in the xmit code at the
same time since RUNNING bit is held. Hence getting this lock early or
late should not matter for the xmit side (and you are also holding
dev->queue_lock while running prep so no new skbs can also be added to
the dev during this time). And I couldn't find any driver that uses the
same tx_lock on rx, so where is the saving by doing prep ?

- KK

