From: Henrik Petander <lpetande@morphine.tml.hut.fi>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Mon, 9 Jun 2003 12:06:35 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.44.0306091140470.25126-100000@morphine.tml.hut.fi>
References: <20030606223057.41ac1c9d.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>,
   <vnuorval@tcs.hut.fi>, <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>,
   <netdev@oss.sgi.com>, <ajtuomin@morphine.tml.hut.fi>, <jagana@us.ibm.com>,
   <kumarkr@us.ibm.com>, <usagi-core@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <20030606223057.41ac1c9d.nakam@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Jun 2003, Masahide NAKAMURA wrote:
>
> We don't think we have to change the logic handling policy with
> the reason because we can treat MIPv6 policy just like IPsec.
>
> When we want to apply both MIPv6 and IPsec to the same target,
> we need one policy that has two or more of templates(e.g. one is
> MIPv6's template and the other is IPsec's).

Does this also mean that the IPSec and MIPv6 policies and SAs need to be
configured at the same time or is it possible to add templates to an
existing policy?


>
> Regarding above case, however, we have a problem like below:
>
> draft(9.3.1 in draft-ietf-mobileip-ipv6-22) says,
>
>   When attempting to verify AH authentication data in a packet that
>   contains a Home Address option, the receiving node MUST calculate
>   the AH authentication data as if the following were true: The Home
>   Address option contains the care-of address, and the source IPv6
>   address field of the IPv6 header contains the home address.


Yes, and this also applies to routing header types 0 and 2. They also need
to be processed by AH so that the addresses are as the receiver sees them
after processing the headers: home address in destination address and
care-of address in the routing header. This is just not said in the mipv6
spec as the routing header IPSec interactions are not specified by it.

>
> Because xfrm decides to call dst_output in the order of templates,
> at first we had no idea which is the former template, MIPv6 or IPsec(Home
> Address Option or AH).

MIPv6 headers should be added first for AH to work.

A different issue related to the different addresses is that the SPD
lookup should be done with the original source address, i.e. home address,
if home address option is used and with the final destination address, if
routing header is used. SPD lookup works now for TCP (with RT header), but
not for raw sockets, which the mipv6 daemon will use. We will provide a
patch for fixing the SPD lookups with raw sockets, which add routing
header and home address option from socket options.

Henrik
		----------------------------------
		Henrik Petander
		Helsinki University of Technology,
		GO/Core Project
		Henrik.Petander@hut.fi
		Office: +358 (0)9 451 5846
		GSM: +358 (0)40 741 5248
		----------------------------------
