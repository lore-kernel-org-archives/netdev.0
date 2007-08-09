From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 3/14] nes: connection manager routines
Date: Thu, 09 Aug 2007 10:37:10 -0700
Message-ID: <ada1wecobi1.fsf@cisco.com>
References: <200708080050.l780oGxo004694@neteffect.com>
	<46B9207D.6000905@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ggrundstrom@neteffect.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:14602 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965964AbXHIRhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 13:37:19 -0400
In-Reply-To: <46B9207D.6000905@garzik.org> (Jeff Garzik's message of "Tue, 07 Aug 2007 21:46:37 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > +atomic_t cm_connects;
 > > +atomic_t cm_accepts;
 > > +atomic_t cm_disconnects;
 > > +atomic_t cm_closes;
 > > +atomic_t cm_connecteds;
 > > +atomic_t cm_connect_reqs;
 > > +atomic_t cm_rejects;
 > 
 > do you really want to take the hit of a LOCK prefix each time you
 > increment a stat???

I think these are once-per-connection things, so the overhead is not
that bad.  On the other hand there's probably another lock you have to
take anyway so maybe you can just define that these are protected by
some lock you take anyway.

Also, these names seem kind of generic to be global -- a nes_ prefix
is probably appropriate.

 - R.
