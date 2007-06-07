From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Thu, 7 Jun 2007 09:59:14 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902FC675E@orsmsx414.amr.corp.intel.com>
References: <20070607090840.346f6a09@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hadi@cyberus.ca>, <kaber@trash.net>, <netdev@vger.kernel.org>,
	<jeff@garzik.org>, "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:14863 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762449AbXFGQ7U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 12:59:20 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070607090840.346f6a09@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > If they have multiple TX queues, independantly programmable, that 
> > single lock is stupid.
> > 
> > We could use per-queue TX locks for such hardware, but we can't 
> > support that currently.
> 
> There could be bad packet reordering with this (like some SMP 
> routers used to do).

My original multiqueue patches I submitted actually had a per-queue Tx
lock, but it was removed since the asymmetry in the stack for locking
was something people didn't like.  Locking a queue for ->enqueue(),
unlocking, then locking for ->dequeue(), unlocking, was something people
didn't like very much.  Also knowing what queue to lock on ->enqueue()
was where the original ->map_queue() idea came from, since we wanted to
lock before calling ->enqueue().

-PJ
