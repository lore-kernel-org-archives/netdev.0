From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Tue, 07 Jun 2005 14:19:22 +0900 (JST)
Message-ID: <20050607.141922.65612976.yoshfuji@linux-ipv6.org>
References: <OF68DFE8BB.D1DDCA2A-ON88257018.0068C3C7-88257018.006CCE31@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OF68DFE8BB.D1DDCA2A-ON88257018.0068C3C7-88257018.006CCE31@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF68DFE8BB.D1DDCA2A-ON88257018.0068C3C7-88257018.006CCE31@us.ibm.com> (at Mon, 6 Jun 2005 13:48:26 -0600), David Stevens <dlstevens@us.ibm.com> says:

> I've been looking at RFC 3542 (Advanced Sockets API) compliance,
> and found the following:
> 
> ("x" is one of {PKTINFO, HOPLIMIT, RTHDR, DSTOPTS, TCLASS })

Well, this breaks API.

Please rename old options, say:

  IPV6_PKTINFO => IPV6_2292PKTINFO
  IPV6_HOPLIMIT => IPV6_2292HOPLIMI
  IPV6_RTHDR => IPV6_2292RTHDR
  IPV6_DSTOPTS => IPV6_2292DSTOPTS

And, add allocate new values for 2292bis options like:

#define IPV6_RECVPKTINFO               48      /* RFC2292bis */
#define IPV6_PKTINFO                   49      /* RFC2292bis */
#define IPV6_RECVHOPLIMIT              50      /* RFC2292bis */
#define IPV6_HOPLIMIT                  51      /* RFC2292bis */
#define IPV6_RECVRTHDR                 52      /* RFC2292bis */
#define IPV6_RTHDR                     53      /* RFC2292bis */
#define IPV6_RECVHOPOPTS               54      /* RFC2292bis */
#define IPV6_HOPOPTS                   55      /* RFC2292bis */
#define IPV6_RECVDSTOPTS               56      /* RFC2292bis */
#define IPV6_DSTOPTS                   57      /* RFC2292bis */
#define IPV6_RECVRTHDRDSTOPTS          58      /* RFC2292bis */
#define IPV6_RTHDRDSTOPTS              59      /* RFC2292bis */

(This is what KAME people did, and I believe that it is the best way to keep
backward compatibility.)

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
