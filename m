From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 6 Mar 2007 18:20:45 +0100
Message-ID: <200703061820.45986.dada1@cosmosbay.com>
References: <20070305.202632.74752497.davem@davemloft.net> <200703061518.09309.dada1@cosmosbay.com> <17901.40819.204568.650642@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se, npiggin@suse.de
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:42158 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965363AbXCFRUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 12:20:47 -0500
In-Reply-To: <17901.40819.204568.650642@robur.slu.se>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 06 March 2007 18:05, Robert Olsson wrote:
> Eric Dumazet writes:
>  > Indeed. It would be nice to see how it performs with say 2^20
>  > elements... Because with your data, I wonder if the extra complexity of
>  > the trash is worth it (since most lookups are going to only hit the hash
>  > and give the answer without intermediate nodes)
>
>  I don't know if I understand you fully. Yes in most cases the first lookup
> via "hash-header" will take us to direct to the correct leaf. If there are
> "collisions" we have to sort them out by adding intermediate nodes.

With 2^20 entries, your actual limit of 2^19 entries in root node will 
probably show us quite different numbers for order-1,2,3,4... tnodes

>
>  Something like where you have resizable hash where is each bucket in turn
> is a resizable hash etc.

Yes, numbers you gave us basically showed a big root node, and mainly leaves 
and very few tnodes.

I was interested to see the distribution in case the root-node limit is hit, 
and we load into the table a *lot* of entries.

