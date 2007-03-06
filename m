From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC PATCH]: Dynamically sized routing cache hash table.
Date: Tue, 6 Mar 2007 15:18:09 +0100
Message-ID: <200703061518.09309.dada1@cosmosbay.com>
References: <20070305.202632.74752497.davem@davemloft.net> <45ED14E6.7090109@cosmosbay.com> <17901.28634.359369.341093@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se, npiggin@suse.de
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:39315 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965049AbXCFOSM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 09:18:12 -0500
In-Reply-To: <17901.28634.359369.341093@robur.slu.se>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 06 March 2007 14:42, Robert Olsson wrote:
> Eric Dumazet writes:
>  > Well, maybe... but after looking robert's trash, I discovered its model
>  > is essentially a big (2^18 slots) root node (our hash table), and very
>  > few order:1,2,3 nodes.
>
>  It's getting "hashlike" yes. I guess all effective algorithms today is
> doing some sort of "index" lookup and for large number of entries we cannot
> expect to find the next node in the same cache line so the "tree depth"
> becomes a crucial performance factor. IMO nothing can beat a prefect
> distributed and perfect sized hash. The trash work is an effort to get
> close with dynamic data structure.

Indeed. It would be nice to see how it performs with say 2^20 elements...
Because with your data, I wonder if the extra complexity of the trash is worth 
it (since most lookups are going to only hit the hash and give the answer 
without intermediate nodes)
