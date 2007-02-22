From: David Miller <davem@davemloft.net>
Subject: Re: Extensible hashing and RCU
Date: Thu, 22 Feb 2007 01:06:38 -0800 (PST)
Message-ID: <20070222.010638.27784211.davem@davemloft.net>
References: <200702211038.24349.dada1@cosmosbay.com>
	<20070221095755.GB308@2ka.mipt.ru>
	<f2b55d220702211315h1266d25el4a0f46c4fb65e12a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, dada1@cosmosbay.com, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: medwards.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60332
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1945953AbXBVJGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 04:06:39 -0500
In-Reply-To: <f2b55d220702211315h1266d25el4a0f46c4fb65e12a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael K. Edwards" <medwards.linux@gmail.com>
Date: Wed, 21 Feb 2007 13:15:51 -0800

> it had better be a 2-left hash with a compact
> overflow pool for the rare case of second collision.

Just like Evgeniy, you should do your research too :-))))

The gain for multiple-hash schemes, such as 2-left, exists only if you
can parallelize the N lookups in hardware.  This is an assumption
built into all the papers you will read on this subject, including the
one you reference by Mitzenmacher.

If you read any paper on IP route lookup algorithms, prefix
your reading of that paper with something that reads like:

	And by the way we are targeting implementations in
	hardware that can parallelize and pipeline memory
	accesses to fast SRAM.  Do not consider this algorithm
	seriously for running on general purpose processors
	in software.

Probably a few read's of Network Algorithmics would help your
understanding in this area as well.

Tries and similar structures do help in the case of our routing
because we're going from a potential 32-hashtable probe down
to a relatively small number of probes into a trie.  That's what
Robert's LC-Trie and upcoming TRASH work do.

But it won't help the same when going from hashes to a trie,
as would be the case for TCP.

If we can get the sockets into the TRASH entries, as Eric will
experiment with, we'll be able to eliminate the TCP hash lookup
in the fast path entirely.  It is the only reasonable suggestion
I've seen made in this area to date.
