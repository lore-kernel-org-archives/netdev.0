From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [Lksctp-developers] [RFC v3 PATCH 2/21] SCTP:
	Convert	bind_addr_list locking to RCU
Date: Thu, 13 Sep 2007 12:56:25 -0700
Message-ID: <1189713386.2748.28.camel@w-sridhar2.beaverton.ibm.com>
References: <46E85344.1030402@hp.com>
	 <11896310224146-git-send-email-vladislav.yasevich@hp.com>
	 <20070912223352.GJ9830@linux.vnet.ibm.com>
	 <1189706346.2748.20.camel@w-sridhar2.beaverton.ibm.com>
	 <46E9908E.6000905@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:54028 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755066AbXIMUA7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 16:00:59 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8DK0xJD011688
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 16:00:59 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8DK0xFZ604000
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 16:00:59 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8DK0wHf030375
	for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 16:00:59 -0400
In-Reply-To: <46E9908E.6000905@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-09-13 at 15:33 -0400, Vlad Yasevich wrote:
> Hi Sridhar
> 
> Sridhar Samudrala wrote:
> > On Wed, 2007-09-12 at 15:33 -0700, Paul E. McKenney wrote:
> >> On Wed, Sep 12, 2007 at 05:03:42PM -0400, Vlad Yasevich wrote:
> >>> [... and here is the updated version as promissed ...]
> >>>
> >>> Since the sctp_sockaddr_entry is now RCU enabled as part of
> >>> the patch to synchronize sctp_localaddr_list, it makes sense to
> >>> change all handling of these entries to RCU.  This includes the
> >>> sctp_bind_addrs structure and it's list of bound addresses.
> >>>
> >>> This list is currently protected by an external rw_lock and that
> >>> looks like an overkill.  There are only 2 writers to the list:
> >>> bind()/bindx() calls, and BH processing of ASCONF-ACK chunks.
> >>> These are already seriealized via the socket lock, so they will
> >>> not step on each other.  These are also relatively rare, so we
> >>> should be good with RCU.
> >>>
> >>> The readers are varied and they are easily converted to RCU.
> >> Looks good from an RCU viewpoint -- I must defer to others on
> >> the networking aspects.
> >>
> >> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > 
> > looks good to me too. some minor typos and some comments on
> > RCU usage comments inline.
> > 
> > Also, I guess we can remove the sctp_[read/write]_[un]lock macros
> > from sctp.h now that you removed the all the users of rwlocks
> > in SCTP
> > 
> 
> Looks like some of the hashing calls still use sctp_write_[un]lock
> macros, but use normal read_lock() for the read side.
> 
> I'll clean that up after these patches are accepted.

OK. You may also consider looking into the generic inet_hashtable
infrastructure and see if we can use it for SCTP.

Thanks
Sridhar

