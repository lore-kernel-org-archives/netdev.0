From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] repairing rtcache killer
Date: Thu, 7 Aug 2003 00:57:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16177.34776.207150.232716@robur.slu.se>
References: <20030806005224.4798f744.davem@redhat.com>
	<200308062123.BAA02118@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com (David S. Miller), Robert.Olsson@data.slu.se,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200308062123.BAA02118@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


kuznet@ms2.inr.ac.ru writes:

 > Robert, look, the idea is:
 > 
 > 1. Periodically we reset elasticity2 to 2*elasticity, f.e. from
 >    periodic gc timer.

 This solve the "positive" feedback. Actually the code I tested moved
 from elasticity2=1 to elasticity*2 as well but this seems more reliable.
 
 > 2. We measure hits and misses with higher frequency, f.e. from
 >    forced gc. The measurement are suppressed for some time
 >    after each flush while cache collects new fresh entries.

 And the measure (forced gc) should not be inhibited by any elastiticy2 
 setting. 


 >     if (misses > rt_hash_mask+1 && hits < misses)
 >            elasticity2 = 0;
 >     else
 >            elasticity2 = 2*elasticity;

	( hits < misses )
 
 Delicate balancing point but actually it didn't look too bad in the
 lab setup.
 
 > misses > rt_hash_mask+1 guarantees that cache is populated and probed
 > enough, rt_hash_mask+1 is not a random number, it corresponds
 > to maximal size with elasticity2 = 0.

 Yes better.

 > Seems, it should work. And it is simple enough.

 Let's try... ;-)

 Cheers.
						--ro
