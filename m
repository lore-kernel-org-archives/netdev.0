From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: 2.6.10 dst cache overflow
Date: Wed, 16 Feb 2005 15:28:31 +0100
Message-ID: <16915.22671.276946.919243@robur.slu.se>
References: <1108550412.3799.81.camel@ts2.office.netland.nl>
	<42134E22.4030808@davidcoulson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "J. Simonetti" <jeroens@office.netland.nl>, netdev@oss.sgi.com
To: David Coulson <david@davidcoulson.net>
In-Reply-To: <42134E22.4030808@davidcoulson.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



David Coulson writes:
 > J. Simonetti wrote:
 > > I have a linux (Fedora core 3) based router. I does approximately 50Mbps
 > > aggregated traffic. However once every week (approx) the router dies
 > > with 'kernel: dst cache overflow' messages flooding syslog. I have
 > > tracked it down to being an issue with the routing cache.
 > 
 > Funny this came up now - One of my core routers failed last night with 
 > the identical problem. The route cache was set to 131k routes, although 
 > I couldn't get a sh prompt on the box even once the switch ports were 
 > down... Had to sysrq-b it.
 > 
 > I'm running 2.6.11-rc1-bk8 right now on those boxes. 20ish day uptime 
 > until yesterday and handling around 12Mbit of traffic. 'route -Cn | wc 
 > -l' right now shows around 29k routes cached. I cranked the route cache 
 > up to 1m entries, but I figure that's probably excessive.

Hello!

Very recently here on netdev "Memory leak in 2.6.11-rc1" was discussed 
this resulted in:
 
> ===== net/ipv4/ip_output.c 1.74 vs edited =====
> --- 1.74/net/ipv4/ip_output.c	2005-01-25 01:40:10 +01:00
> +++ edited/net/ipv4/ip_output.c	2005-01-30 18:54:43 +01:00
> @@ -389,6 +389,7 @@
>  	to->priority = from->priority;
>  	to->protocol = from->protocol;
>  	to->security = from->security;
> +	dst_release(to->dst);
>  	to->dst = dst_clone(from->dst);
>  	to->dev = from->dev;  

and a similar patch for ipv6. Should be a start.


						--ro
