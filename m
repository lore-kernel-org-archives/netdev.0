From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] repairing rtcache killer
Date: Thu, 7 Aug 2003 01:23:18 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308062123.BAA02118@dub.inr.ac.ru>
References: <20030806005224.4798f744.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030806005224.4798f744.davem@redhat.com> from "David S. Miller" at Aug 06, 2003 12:52:24 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> >  > #   Two serious and interesting mistakes were made in the patch of 2003-06-16.
> 
> Mama mia!  This patch exists in 2.4.22-preX too, so full fix
> becomes more urgent.

I exaggerated saying "serious". The emphasize is rather on "interesting". :-)
Mistake were not evident, Robert and me spent day and half to figure out
what the hell is going on. :-) It shows only at high flow rate and it is just
suboptimal thing, not a disaster.


> Alexey, given all this what would you like to do?  Should I push
> your patch urgently into 2.4.x or spend some more time trying to
> solve this issue?

Hour ago I would say "yes". But this bus trip happened
to be productive. :-) Seems, I know how to do right thing.
I will code it now, and if Robert will be happy...

Robert, look, the idea is:

1. Periodically we reset elasticity2 to 2*elasticity, f.e. from
   periodic gc timer.
2. We measure hits and misses with higher frequency, f.e. from
   forced gc. The measurement are suppressed for some time
   after each flush while cache collects new fresh entries.

   F.e.
 
    if (misses > rt_hash_mask+1 && hits < misses)
           elasticity2 = 0;
    else
           elasticity2 = 2*elasticity;

misses > rt_hash_mask+1 guarantees that cache is populated and probed
enough, rt_hash_mask+1 is not a random number, it corresponds
to maximal size with elasticity2 = 0.

Seems, it should work. And it is simple enough.
          
Alexey
