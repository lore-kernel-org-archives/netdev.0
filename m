From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC][PATCH] net drivers and cache alignment
Date: Sun, 08 Dec 2002 12:00:44 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021208.120044.08024570.davem@redhat.com>
References: <3DF2844C.F9216283@digeo.com>
	<20021207.153045.26640406.davem@redhat.com>
	<3DF28748.186AB31F@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@digeo.com
In-Reply-To: <3DF28748.186AB31F@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andrew Morton <akpm@digeo.com>
   Date: Sat, 07 Dec 2002 15:42:00 -0800

   "David S. Miller" wrote:
   > non-smp machines lack L2 caches?  That's new to me :-)
   > 
   > More seriously, there are real benefits on non-SMP systems.
   
   Then I am most confused.  None of these fields will be put under
   busmastering or anything like that, so what advantage is there in
   spreading them out?
   
When you are in the "tx path" you'll take one L2 cache miss
to bring all the necessary information into the cpu's caches.

Otherwise, when data is arbitrarily scattered over multiple L2
cache lines, you'll need to service potentially more L2 cache
misses.

This optimization has nothing to do with false data sharing amoungst
multiple processors.  It's about packing the data accesses optimally
for specific code paths.
