From: jamal <hadi@cyberus.ca>
Subject: RE: IPv4 and IPv6 stack multi-FIB, scalable in the million of
	entries.
Date: 08 Apr 2004 21:05:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1081472721.1041.99.camel@jzny.localdomain>
References: <019e01c41da3$36aae260$0348858e@D4SF2B21>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, "David S. Miller" <davem@redhat.com>,
        ak@muc.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mathieu Giguere <Mathieu.Giguere@ericsson.ca>
In-Reply-To: <019e01c41da3$36aae260$0348858e@D4SF2B21>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mathieu,

What i would recommend to you is the following: Make your algorithm
changes; test them, come with some perfomance numbers in comparison
with what Linux already does for the same kernel version. Then you
have ammunition to use for an arguement.

cheers,
jamal

On Thu, 2004-04-08 at 15:53, Mathieu Giguere wrote:
>  Hi,
> 
>      Just run the join script on your favorite 2.4 kernel.
> 
>  RTNETLINK answers: Cannot allocate memory
>  RTNETLINK answers: Cannot allocate memory
>  RTNETLINK answers: Cannot allocate memory
>  [root@tom tmp]# ip -6 route | wc -l
>     4094
>  [root@tom tmp]#
> 
> 
>      And after 4094 IPv6 routes you will the get the same.
> 
>      For the PMTU, the info can't be retain in the route himself.  The PTMU
>  is base on DIP not on the current network routing.  So it must be kept in a
>  separate hash struct with expire time.  _BUT_ you must not flush all the
>  entries each time a route is added or  deleted like in the current
>  implementation.
> 
>  /mathieu
> 
> 
>  -------------------------------
>  #!/bin/csh
>  echo #!/bin/sh
>  set addr1=0
>  set addr2=1
>  while ($addr1 < 256)
>    while ($addr2 < 256)
>      echo ip -f inet6 route add 2000:${addr1}::${addr2}/128 dev eth0
>      @ addr2++
>    end
>    set addr2=0
>    @ addr1++
>  end
> 
> 
>  ----- Original Message ----- 
>  From: "David S. Miller" <davem@redhat.com>
>  To: "Mathieu Giguere" <Mathieu.Giguere@ericsson.ca>
>  Cc: <ak@muc.de>; <netdev@oss.sgi.com>; <linux-kernel@vger.kernel.org>
>  Sent: Thursday, April 08, 2004 2:33 PM
>  Subject: Re: IPv4 and IPv6 stack multi-FIB, scalable in the million of
>  entries.
> 
> 
>  > On Thu, 8 Apr 2004 14:10:43 -0400
>  > "Mathieu Giguere" <Mathieu.Giguere@ericsson.ca> wrote:
>  >
>  > > The main goal to remove the routing cache is to avoid to have 4096
>  routes
>  > > limitation
>  >
>  > This 4K routes limitation is news to everyone who works on this
>  > code.
>  >
>  > When nexthop changes we _MUST_ flush PMTU etc. information because that
>  > could have changed.  If however, such information is locked into the
>  > route itself, it will propagate immediately into the routing cache
>  > entry once recreated.
>  >
>  > You seem to be talking about a lot of non-problems, but this may because
>  > you're not providing enough details.
>  >
> 
> 
> 
