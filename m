From: Rod Van Meter <Rod.VanMeter@nokia.com>
Subject: Re: Chaotic structure of the net headers?
Date: 05 Mar 2003 15:10:35 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1046905834.17778.400.camel@localhost.localdomain>
References: <20030305225441.GO20423@fs.tum.de>
Reply-To: Rod.VanMeter@nokia.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ext Adrian Bunk <bunk@fs.tum.de>
In-Reply-To: <20030305225441.GO20423@fs.tum.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-03-05 at 14:54, ext Adrian Bunk wrote:

> 
> There's some duplication, e.g. include/linux/in6.h contains
> 
> /*
>  *      IPV6 extension headers
>  */
> #define IPPROTO_HOPOPTS         0       /* IPv6 hop-by-hop options      */
> #define IPPROTO_ROUTING         43      /* IPv6 routing header          */
> #define IPPROTO_FRAGMENT        44      /* IPv6 fragmentation header    */
> #define IPPROTO_ICMPV6          58      /* ICMPv6                       */
> #define IPPROTO_NONE            59      /* IPv6 no next header          */
> #define IPPROTO_DSTOPTS         60      /* IPv6 destination options     */


According to RFC2292 (Advanced Sockets):

2.1.1.  IPv6 Next Header Values

   IPv6 defines many new values for the Next Header field.  The
   following constants are defined as a result of including
   <netinet/in.h>.

   #define IPPROTO_HOPOPTS        0 /* IPv6 Hop-by-Hop options */
   #define IPPROTO_IPV6          41 /* IPv6 header */
   #define IPPROTO_ROUTING       43 /* IPv6 Routing header */
   #define IPPROTO_FRAGMENT      44 /* IPv6 fragmentation header */
   #define IPPROTO_ESP           50 /* encapsulating security payload */
   #define IPPROTO_AH            51 /* authentication header */
   #define IPPROTO_ICMPV6        58 /* ICMPv6 */
   #define IPPROTO_NONE          59 /* IPv6 no next header */
   #define IPPROTO_DSTOPTS       60 /* IPv6 Destination options */

   Berkeley-derived IPv4 implementations also define IPPROTO_IP to be 0.
   This should not be a problem since IPPROTO_IP is used only with IPv4
   sockets and IPPROTO_HOPOPTS only with IPv6 sockets.


> 
> and include/net/ipv6.h contains:
> 
> <--  snip  -->
> 
> /*
>  *      NextHeader field of IPv6 header
>  */
> 
> #define NEXTHDR_HOP             0       /* Hop-by-hop option header. */
> #define NEXTHDR_TCP             6       /* TCP segment. */
> #define NEXTHDR_UDP             17      /* UDP message. */
> #define NEXTHDR_IPV6            41      /* IPv6 in IPv6 */
> #define NEXTHDR_ROUTING         43      /* Routing header. */
> #define NEXTHDR_FRAGMENT        44      /* Fragmentation/reassembly header. */

This form doesn't appear in RFC2292, nor in 2133 (Basic Socket...)

My interpretation is that this latter form is defined for kernel use,
while the former is for user-level manipulation of raw packet fields
(the primary purpose of 2292).

Does it make sense to have two forms, one kernel, one user?  I haven't
e.g. followed the desired include chain.  If we wanted to merge the
uses, the former form and include location would probably have to be
used.

I've been looking into this.  There are a *few* things missing from the
2292 support.  AFAICT, it's just a handful of functions/macros for
manipulating option headers that need to be added.

Does anybody actually USE this stuff (the advanced sockets API, I mean,
not IPv6)?  I'm planning to add those missing bits, just for kicks, but
haven't done it yet.

			--Rod
