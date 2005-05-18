From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Thu, 19 May 2005 07:45:26 +1000
Message-ID: <E1DYWM2-0004jM-00@gondolin.me.apana.org.au>
References: <428B6B72.5010407@hp.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rick.jones2@hp.com (Rick Jones)
In-Reply-To: <428B6B72.5010407@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> wrote:
> If we ass-u-me that the sender is indeed using a random IP ID assignment 
> mechanism, 30000 is probably too many.  There are only 65536 possible ID's, and 
> if we "choose" 30000 of them there will undoubtedly be many duplicated.  Someone 
> who didn't fall asleep too often in ProbStats (unlike myself) can probably tell 
> us just how many.

IMHO hosts using purely random IDs all the time are fundamentally broken
for applications such as NFS over UDP over gigabit.  However, in order
to handle such hosts we should make this threshold configurable and
then those who need it can set it to a value like 600 which gives a
collision probability with the first fragment of just less than 1%.

> Also, I think the count has to be _any_ IP datagram on that src/dst pair, 
> fragmented or not.  Someone else pointed-out the possiblity of sending use one 
You might be there.  However, we should keep in mind that we're not
trying to come up with a perfect solution to the IP fragmentation
problem.  All we need is something that's good enough to deal with
usages similar to NFS over UDP over gigabit.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
