From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [patch]: ipv6 tunnel for MIPv6
Date: Thu, 05 Jun 2003 00:49:32 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030605.004932.00042147.yoshfuji@linux-ipv6.org>
References: <20030531.003858.108351451.yoshfuji@linux-ipv6.org>
	<20030603.213830.85382657.davem@redhat.com>
	<3EDE0286.4000304@tml.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, vnuorval@tcs.hut.fi, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi,
   lpetande@morphine.tml.hut.fi, jagana@us.ibm.com, kumarkr@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: lpetande@tml.hut.fi
In-Reply-To: <3EDE0286.4000304@tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.


In article <3EDE0286.4000304@tml.hut.fi> (at Wed, 04 Jun 2003 17:30:30 +0300), Henrik Petander <lpetande@tml.hut.fi> says:

> 2. Source address based routing
> 
> Ville sent the patch. The semantical changes to the original code were
> in our opinion necessary to get source address based routing working
> more as IPv4 policy routing.  Let's discuss this more.

I'm not sure why you need this (and tunnel) for MIP...
Would you clearify for me?
(IMHO, I believe we don't need this change if we use XFRM engine.)

BTW, source based routing (source address is major, destination is minor)
is done by policy routing; It is NOT the task of CONFIG_IPV6_SUBTREE, IMHO.
Yes, poeple want to have policy routing, but it is NOT (only) for MIP6.


> 3. API
:
> There is a (sub)group working on MIPv6 extensions to the Advanced Socket
> API for IPv6.  To me it seems pointless to add anything other to the
> spec than a way to insert a destination option header to the third
> possible DO position (i.e. between routing header and fragmentation
> header).  This could be done just by adding new type, let's call it
> IPV6_NOFRAGDSTOPTS.  Everything else should be doable with the
> existing ASA.  We would like to hear comments on this.

No, user daemon adds a XFRM policy for adding destination option 
(and/or routing header).  Stackable destination will do the real work.
(So, we don't need socket options.)


> 4. Source address selection
> 
> We think adding new home address flag to addresses is the best and
> easiest way making the source address selection to work with MIPv6.
> I'm sure USAGI will add the relevant checks to their source address
> selection code for that.  Dave, Antti already brought this up some weeks
> ago, but got no answer. Is the home address bit OK with you?

"Yes," is my answer for now.


> 5. MIPv6 extension header adding
:
> Storing of the mipv6 information would in our opinion be achieved more
> cleanly by using cached routes which included the mipv6 information (two
> extra addresses and flags). The routes would contain modified nexthop
> information and mip6_output as the  rt->u.dst.output function.
> Mip6_output would add the extension headers based on the information
> stored in the route. The routes would have a stacked dst entry, which
> would be used for actual output.

I still belive it is very natural to use XFRM to manage stackable 
destination.


> Our prototype  currently works with tcp, tcp + ipsec and raw sockets,
> but has only a hackish interface through route ioctl for testing. I can
> send a preview patch of the code for discussion, if the general approach
> makes sense to you. I would like to hear your opinions on this and also
> if you (USAGI) have planned something else for storing the mipv6 state.

Okay, anyway, please sent it to David, Alexey and me (at least).
We can learn more from the code than documentation. ;-)

Thank you.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
