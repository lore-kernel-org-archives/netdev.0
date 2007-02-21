From: David Miller <davem@davemloft.net>
Subject: Re: Extensible hashing and RCU
Date: Wed, 21 Feb 2007 05:37:21 -0800 (PST)
Message-ID: <20070221.053721.112287244.davem@davemloft.net>
References: <200702201209.52388.dada1@cosmosbay.com>
	<p73y7mrd6o9.fsf@bingen.suse.de>
	<200702211419.30856.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, johnpol@2ka.mipt.ru, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36627
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161232AbXBUNhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 08:37:22 -0500
In-Reply-To: <200702211419.30856.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 21 Feb 2007 14:19:30 +0100

> Now, when the rate of lookups/inserts/delete is high, with totally random 
> endpoints and cache *always* cold , 'tree structures' are not welcome (not 
> cache friendly)

But what about if tree lookup were free :-)

This is why I consider Robert Olsson's trash work the most promising,
if we stick sockets into his full flow identified routing cache trie
entries, we can eliminate lookup altogether.

Just like how he already uses traffic inspection to kill cache entries
when FIN shutdown sequence is snooped, we can explicitly flush such
entries when socket is closed fully on local system.

Really, possibilities are truly endless with that thing.
