From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sat, 28 Sep 2002 07:35:57 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0209280726010.8405-100000@netcore.fi>
References: <200209280419.IAA02894@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <yoshfuji@linux-ipv6.org>,
   <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>,
   <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200209280419.IAA02894@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 28 Sep 2002 kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> > Alexey, I still am not clear, this belongs in the output routing logic
> > right?
> ...
> > where source address selection belongs.
> 
> Yes, it naturally belongs to the time when route is created.
> 
> This is just extending ipv6 routing entry with a field to hold
> source address and, generally, making the same work as IPv4 does,
> with all the advantages, particularily capability to select preferred
> source address via routes set up by admin (RTA_PREFSRC attribute,
> "src" in "ip route add").

Umm.. you sure?

Isn't putting this logic to routes an oversimplification?

Consider e.g. a dummy host which only have a few address (link-local,
site-local, global; the last two /64's) and, basically, a default route
(plus of course an interface routes for those /64's).

When talking to other subnets within the site (ie. those not on the /64)  
one would have difficulties parsing the source address from the default
route, as there would have to be at least two candidates there.

Am I missing something obvious here?

Alexey's approach should work in some simpler cases, but maybe not all
(stuff that's network prefix -independent like home addresses, privacy
addresses etc. would be different).

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
