From: "CIT/Paul" <xerox@foonet.net>
Subject: RE: Route cache performance under stress
Date: Sun, 8 Jun 2003 19:55:58 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <001001c32e19$81bc7ea0$4a00000a@badass>
References: <20030608234926.GA9453@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "'Simon Kirby'" <sim@netnation.com>,
	"'Florian Weimer'" <fw@deneb.enyo.de>
In-Reply-To: <20030608234926.GA9453@netnation.com>
List-Id: netdev.vger.kernel.org

The problem with the route cache as it stands is that it adds every new
packet that isn't in the route cache to the cache, say you have 
A denial of service attack going on, OR you just have millions of hosts
going through the router (if you were an ISP).  Anything with seeminly
Random source ips (something like juno-z.101f.c will generate worst case
scenario for forwarding packets) will cause the cache to constantly
Add new entries at pretty much the rate of the attack.. This can stifle
just about any linux router with a measly 10 megabits/second of traffic
unless
The router is tuned up to a large degree (NAPI, certain nics, route
cache timings, etc.) and even then it can still be destroyed no matter
what
The cpu is with less than 100,000 packets per second and in mosts cases
less than 30k.. That's why it's just no acceptable for companies using
it as a replacement for say a cisco 7200 VXR series (npe300,400 nsf-1,
etc.) which can do 300K+ packet per second of routing (and yes it can
even route juno-z.101f.c at 300kpps, I have tested it).   Linux has no
problem doing 300kpps from a single source to a single destination
provided you have NAPI or ITR or something limiting the interrupts.. The
overhead is the route cache and the related systems that use it and also
netfilter is very slow :/  One of these days they will fix it..... If
anyone has any ideas or needs a test-bed to try out code on or would
like me to test some of their code I would be happy to test it on our
development platforms (single and dual processor with intel e1000
82545/6 and above, also e100 and tulip). 

Thanks for your time

P.S. to answer your iteration question.. It does not seem to be such
overhead on the cpu even if the route-cache is 600,000 in size.. I have
tested this and while there is a definite increase in cpu it comes
nothing close to the code that has to add every new arriving packet to
the list.  IMHO the best way to do this would be like CEF w/ adjacency
lists and not have it add every new packet that comes along 

Paul xerox@foonet.net http://www.httpd.net


-----Original Message-----
From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
Behalf Of Simon Kirby
Sent: Sunday, June 08, 2003 7:49 PM
To: Florian Weimer
Cc: netdev@oss.sgi.com; linux-net@vger.kernel.org
Subject: Re: Route cache performance under stress


On Sun, Jun 08, 2003 at 03:10:25PM +0200, Florian Weimer wrote:

> Further parameters which could be tweaked is the kind of adjacency 
> information (where to store the L2 information, whether to include the

> prefix length in the adjacency record etc.).

What is the problem with the current approach?  Does the overhead come
from having to iterate through the hashes for each prefix?

Simon-

[        Simon Kirby        ][        Network Operations        ]
[     sim@netnation.com     ][   NetNation Communications Inc.  ]
[  Opinions expressed are not necessarily those of my employer. ]

