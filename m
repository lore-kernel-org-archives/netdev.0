From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: removing gotos considered harmful...
Date: Thu, 4 Jan 2007 10:02:59 +0000
Message-ID: <200701041002.59906@strip-the-willow>
References: <20061222.120432.55508411.davem@davemloft.net> <200701030808.08182@strip-the-willow> <20070103.172548.17866275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:62716 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932340AbXADKCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 05:02:51 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20070103.172548.17866275.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

|  > previous code had the form (this is copied from 2.6.17-mm1 original):
|  > 
|  > 			size = 0;
|  > 			sk_for_each(sk2, node, list)
|  > 				if (++size >= best_size_so_far)
|  > 					goto next;
|  > 			best_size_so_far = size;
|  > 			best = result;
|  > 		next:;
|  > 
|  > |  and this got converted into:
|  > |  
|  > |  			sk_for_each(sk2, node, head)
|  > |  				if (++size < best_size_so_far) {
|  > |  					best_size_so_far = size;
|  > |  					best = result;
|  > |  				}
|  > |  
|  > |  Which does something very very different from the original.
|  >
|  > ===> Sorry, I fail to see where the two differ. They have the same postcondition
|  >      upon loop exit; sk2, node, size, and head are not referenced anywhere in the 
|  >      code that follows.
|  >      
|  
|  Please go buy a pair of glasses then :-)
|  
|  They are not at all the same.  Consider in what circumstances the two
|  variables "best_size_so_far" and "best" get updated in the two cases,
|  it's massively different.
|  
|  You _ALWAYS_ update those two variables in your version if the loop
|  executes at least once, that's wrong and that's not what the original
|  code was trying to do.
|  
|  It ONLY wants to update those two variables when we walk
|  a complete hash chain which is smaller than "best_size_so_far".
|  
|  The fact that you continue to try and defend your version shows
|  that you really had no idea what you were doing when you made this
|  change.
|  
|  You added an exploitable hole to our UDP protocol implementation
|  because you didn't understand this snippet of code and wanted to
|  'clean up the logic'.
|  
|  
You are right, I made a stupid error by considering a single construct out of context.

I only understood fully what you were saying above after doing a lengthy paper-and-pencil
analysis of the entire algorithm: the exploit is in the assignment of `best', I was arguing
about `best_size_so_far', which is of no consequence here. 

I apologise for the regression that this caused - in future submissions I make sure that I
do the paper and pencil analysis before. Thanks for patience with the explanation. 
