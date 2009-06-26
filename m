From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Fri, 26 Jun 2009 23:20:10 +0200
Message-ID: <20090626212010.GD6908@ami.dom.local>
References: <20090626151051.GA2714@ami.dom.local> <20090626153010.GC6771@linux.vnet.ibm.com> <20090626155410.GA6526@ami.dom.local> <20090626161500.GB6526@ami.dom.local> <20090626162340.GF6771@linux.vnet.ibm.com> <20090626164557.GB6755@ami.dom.local> <20090626170538.GK6771@linux.vnet.ibm.com> <20090626180544.GA6908@ami.dom.local> <19013.12045.576790.95151@robur.slu.se> <20090626203713.GC6908@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Eric Dumazet <dada1@cosmosbay.com>,
	=?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>, Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:60721 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbZFZVUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 17:20:20 -0400
Received: by bwz9 with SMTP id 9so2259339bwz.37
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 14:20:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090626203713.GC6908@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 10:37:13PM +0200, Jarek Poplawski wrote:
> On Fri, Jun 26, 2009 at 10:26:53PM +0200, Robert Olsson wrote:
> > 
> > 
> > Yes looks like a good solution but maybe it safest to synchronize unconditionally?
> 
> Hmm... I lost around half an hour for this doubt... Sure! (Unless
> there are some strange cases which very often create and destroy very
> small tables?)

...or maybe even only updating such small tables very often?

Btw., Robert, I wondered about some design details lately, especially
about pointer to a parent. I didn't see it in the basic docs, so it
seems it could be avoided. It seems to be a problem with RCU, unless I
miss something: if there were no going back from children to parents
it seems we could free those "temporary" (created by inflate() and
halve() and destroyed before resize() has finished) earlier.

Another problem with this, it seems, are possibly false lookups (if we
go back to the new parent which doesn't have it's parent or other nodes
updated). So, was there so much performance gain to introduce this?

Thanks,
Jarek P.
