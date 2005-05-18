From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 09:21:06 -0700
Message-ID: <428B6B72.5010407@hp.com>
References: <20050517.104947.112621738.davem@davemloft.net>	<E1DYAHF-0006qW-00@gondolin.me.apana.org.au>	<20050518004733.GG13748@postel.suug.ch>	<20050518011632.GA27813@gondor.apana.org.au> <20050518013712.GH13748@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050518013712.GH13748@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If we ass-u-me that the sender is indeed using a random IP ID assignment 
mechanism, 30000 is probably too many.  There are only 65536 possible ID's, and 
if we "choose" 30000 of them there will undoubtedly be many duplicated.  Someone 
who didn't fall asleep too often in ProbStats (unlike myself) can probably tell 
us just how many.

Also, I think the count has to be _any_ IP datagram on that src/dst pair, 
fragmented or not.  Someone else pointed-out the possiblity of sending use one 
fragmetned datagram, then 64K to someone else - well, those 64K to someone else 
could just as easily be 64K non-fragmented IP datagrams to us, so it seems for a 
measure of "out of orderness liklihood" we need to include non-fragmented IP 
datagrams.

The thought of having to do added accounting on a non-fragmented datagram seems 
unpleasant though.

rick jones
