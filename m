From: David Miller <davem@davemloft.net>
Subject: Re: removing gotos considered harmful...
Date: Wed, 03 Jan 2007 17:25:48 -0800 (PST)
Message-ID: <20070103.172548.17866275.davem@davemloft.net>
References: <20061222.120432.55508411.davem@davemloft.net>
	<200701030808.08182@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnaldo.melo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48035
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932234AbXADBZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 20:25:49 -0500
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200701030808.08182@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 3 Jan 2007 08:08:08 +0000

> However, I would also like to plead non-guilty. I have checked - what you
> are quoting is not the original patch. If you look at e.g. 2.6.17-mm1, the 
> previous code had the form (this is copied from 2.6.17-mm1 original):
> 
> 			size = 0;
> 			sk_for_each(sk2, node, list)
> 				if (++size >= best_size_so_far)
> 					goto next;
> 			best_size_so_far = size;
> 			best = result;
> 		next:;
> 
> |  and this got converted into:
> |  
> |  			sk_for_each(sk2, node, head)
> |  				if (++size < best_size_so_far) {
> |  					best_size_so_far = size;
> |  					best = result;
> |  				}
> |  
> |  Which does something very very different from the original.
>
> ===> Sorry, I fail to see where the two differ. They have the same postcondition
>      upon loop exit; sk2, node, size, and head are not referenced anywhere in the 
>      code that follows.
>      

Please go buy a pair of glasses then :-)

They are not at all the same.  Consider in what circumstances the two
variables "best_size_so_far" and "best" get updated in the two cases,
it's massively different.

You _ALWAYS_ update those two variables in your version if the loop
executes at least once, that's wrong and that's not what the original
code was trying to do.

It ONLY wants to update those two variables when we walk
a complete hash chain which is smaller than "best_size_so_far".

The fact that you continue to try and defend your version shows
that you really had no idea what you were doing when you made this
change.

You added an exploitable hole to our UDP protocol implementation
because you didn't understand this snippet of code and wanted to
'clean up the logic'.
