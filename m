From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 14:19:52 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409211412580.1570-100000@netcore.fi>
References: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Netdev List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Sep 2004, Harald Welte wrote:
> 1) should I try to use jhash for ipv6, too?
> 
> 2) Dave has indicated that there should be an upper limit for hash
>    buckets.  What is considered a reasonable upper bound, even for very
>    large systems?
[...]
> 5) What is the proposed solution for IPv6, when you have /48 or /64 bit
>    prefixes and systems become even more vulnerable to neighbour cache
>    attacks?  

The situation with IPv6 is not much different than with IPv4.

It's better in the sense that nobody will be portscanning the whole 
address space or subnets as a means to look for nodes.  So, the 
viruses, worms, exploits etc. will need to use other techniques, so 
the practical need is lower. [and those nodes which try and fall over 
from resource exhaustion .. well, they deserve it ;-)]

It's worse in the sense that there is more space in each subnet for
doing aggressive probing -- but this may not be a big issue with a
good algorithm and a threshold.

In short, I don't think there needs to be anything special for IPv6.  
Just the same mechanisms as for IPv4 -- at some threshold, start 
garbage collecting more aggressively, using a "least-recently-used" 
algorithm (or the like). 

To constraint remote resource exhaustion exploits please make sure 
that the algorithm is sufficiently can also deal with the threat 
described at RFC 3756 section 4.3.2.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
