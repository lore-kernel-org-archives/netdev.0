From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Thu, 12 Jun 2003 14:35:40 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030612.143540.41663883.davem@redhat.com>
References: <16102.9418.43884.336925@robur.slu.se>
	<20030611.234534.52193216.davem@redhat.com>
	<16104.34463.60472.750699@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralph+d@istop.com, ralph@istop.com, hadi@shell.cyberus.ca,
	xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Robert.Olsson@data.slu.se
In-Reply-To: <16104.34463.60472.750699@robur.slu.se>
List-Id: netdev.vger.kernel.org

   From: Robert Olsson <Robert.Olsson@data.slu.se>
   Date: Thu, 12 Jun 2003 15:56:47 +0200

   David S. Miller writes:
   
    > That is a lot more work, but it would validate the various ideas and
    > claims being made.  For example, it would say for sure whether
    > eliminating the routing cache is a win or not for DoS traffic.
   
    Well it's true. But do we need too? From the profile we actually see the 
    'dst' management cost. Not much I would say and still we will need some 
    adminstration i.e refcounting even it we should remove the route hash.

But Robert, do you know "why" the dst management doesn't show up in
your profiles when you rip-out the rtcache?

It's because to total number of DST entries is so small that they all
fit in the cpu cache.  When the rtcache is enabled and we thus have up
to "max_size" DST entries in flight at all times, the dst management
routines show up very clearly because they have a high probability of
missing the cpu cache.

In particular, have a good look at Simon's profiles.  dst_alloc() is
quite near the top there.
