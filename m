From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Sun, 08 Jun 2003 22:44:46 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030608.224446.78724665.davem@redhat.com>
References: <20030608234926.GA9453@netnation.com>
	<001001c32e19$81bc7ea0$4a00000a@badass>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: xerox@foonet.net
In-Reply-To: <001001c32e19$81bc7ea0$4a00000a@badass>
List-Id: netdev.vger.kernel.org

   From: "CIT/Paul" <xerox@foonet.net>
   Date: Sun, 8 Jun 2003 19:55:58 -0400

   The problem with the route cache as it stands is that it adds every new
   packet that isn't in the route cache to the cache, say you have 
   A denial of service attack going on, OR you just have millions of hosts
   going through the router (if you were an ISP).

We perform now rather acceptibly in such scenerios.   Robert Olsson
has demonstrated that even if the attacker could fill up your
entire bandwidth with random source address packets, we'd still
provide 50kpps routing speed.

And this can be made much higher because the performance limiter
is the routing cache GC which isn't tuned properly.  It can't keep
up because it doesn't try to purge the right amount entries each
pass.

All the performance problems I've seen have been algorithmic or
outright bugs.  Bad hash functions and limits in how big the FIB
hash tables would grow.  And what's left is fixing GC.

There is nothing AT ALL fundamental about a routing cache that
precludes it from behaving sanely in the presence of a random source
address DoS load.  Absolutely NOTHING.

   This can stifle just about any linux router with a measly 10
   megabits/second of traffic unless

Not true, that happens because of BUGs.  Not because routing caches
cannot behave sanely in such situations.

   The router is tuned up to a large degree (NAPI, certain nics, route
   cache timings, etc.) and even then it can still be destroyed no matter
   what

And today, this is because of BUGs in how the GC works.  You can
design the GC process so that it does the right thing and recycles
only the DoS entries (those being very non-localized).

You should interact with Robert Olsson who has been doing tests on the
effect of gigabit rate full-on DoS runs where every packet creates a
new routing cache entry.

Franks a lot,
David S. Miller
davem@redhat.com
