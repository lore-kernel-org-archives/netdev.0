From: jamal <hadi@cyberus.ca>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Fri, 3 Jan 2003 23:11:45 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030103224852.L48869@shell.cyberus.ca>
References: <Pine.LNX.4.44.0301032100340.29812-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Greear <greearb@candelatech.com>, Jeff Garzik <jgarzik@pobox.com>,
   "" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
In-Reply-To: <Pine.LNX.4.44.0301032100340.29812-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Too many emails to respond to at once.

Q: Is this a hack?
A: Yes, indeed it is. wrong API is the main culprit.

Q: Is this a feature needed by only a few people?
A: No, Absolutely not. RFC2338 is one example that needs

such a feature for "aliasing" MAC addresses. RFC2338 is very popular
these days for some reason. I would think any schemes
that do HA takeover of another host would need such a feature.

How common are NICS such as the 21x4x that can be programmed to do
perfect hashing and accept multiple MAC addresses in hardware?
And if this was a commodity feature - what happens to PACKET_HOST
setting? an netdevice can only have one unicast MAC address.
SIOCDEVPRIVATE does not seem to be the right place to do this.
You still wanna have ability to do proper RFC2338 and related protocols
even when the h/ware is incapable.
And btw, i didnt even open up the whole can of worms - we also need to
respond back with proper MAC addresses to ARPs and packets sourced with
specific virtual router IPs. This is a seprate problem.

cheers,
jamal

PS: the hack credit (for using SIOCADDMULTI/DELMULTI) goes to Jerome
Ettiene (this is a guy who never responds to email, probably too busy
unicycling somewhere, so no point in ccing him) - Except it doesnt work
without the patch i posted.
On takeover, he sets the original MAC address as a receiving MAC
via SIOCADDMULTI and the allocated 00-00-5E-00-01-xx MAC to be
the main MAC address.
The weakness is when you want to run multiple virtual routers; each
one requires its own 00-00-5E-00-01-xx MAC.
