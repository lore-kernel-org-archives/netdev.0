From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC PATCH] llc: convert the socket list to RCU locking (was Re: [PATCH 3/4] llc: use a device based hash table to speed up multicast delivery)
Date: Wed, 9 Dec 2009 22:36:06 +0200
Message-ID: <200912092236.06298.opurdila@ixiacom.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <200912082310.45846.opurdila@ixiacom.com> <4B20064C.7070301@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:12144 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757713AbZLIUjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 15:39:15 -0500
In-Reply-To: <4B20064C.7070301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 09 December 2009 22:19:24 you wrote:

> > +     rcu_read_lock();
> > +     sk_nulls_for_each_rcu(rc, node, &sap->sk_list) {
> > +             if (llc_estab_match(sap, daddr, laddr, rc)) {
> > +                     /* Extra checks required by SLAB_DESTROY_BY_RCU */
> > +                     if (unlikely(!atomic_inc_not_zero(&rc->sk_refcnt)))
> > +                             continue;
> 
> Hmm, this wont work in fact, because if we have several llc_sap allocated
>  on machine, we have no guarantee a freed socket wont be reused and
>  inserted in another llc_sap list.
> 
> So before calling llc_estab_match() (and/or llc_listener_match()) you
>  should check if 'rc' really belong to current sap.
> 
> If not, you must restart the lookup (you hit a socket that was moved to
>  another sap)
> 

Right ! 

>> 
>> One doubt before pasting the code: In slab.h comment and in udp.c I see the 
lookup is restarted if an improper object is returned. Is that really 
required?
>> 
>
>
>Its needed only if you convert to a hash table (more than one chain),
>and I guess you definitly want a fanout of your XXXX items ?
>
>Check Documentation/RCU/rculist_nulls.txt for details :)

And of course I'll still want to add the hash table ;) I was just trying to 
get my head around something simpler first.

I think I have everything  (in my head :) ) that I need now to come back with 
a v2 llc patch set now. Thanks for your help !

