From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH 1/4] Prefix List against 2.5.73
Date: Tue, 15 Jul 2003 05:17:53 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307150117.FAA06705@dub.inr.ac.ru>
References: <Pine.LNX.4.44.0307141300520.5140-100000@DYN318430.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, davem@redhat.com, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru, krkumar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: krkumar@us.ibm.com (Krishna Kumar)
In-Reply-To: <Pine.LNX.4.44.0307141300520.5140-100000@DYN318430.beaverton.ibm.com> from "Krishna Kumar" at éÀÌ 14, 2003 03:35:15 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> inet6_fill_ifaddr (and introduce RTM_IFACEFLAGS). This will be specific to
> IPv6. Are you agreeable to this ?
...
> +	IFA_IFFLAGS,

What's about ifa_flags? There is some space there, and the things
kept there now: TENTATIVE/DEPRECATED et al. are close relatives
of O/M.


> - I believe we need #3 for the reasons given above.

This does not pass through Occam's razor. Why not to give a filter to plain
RTM_GETROUTE? We did not implement filtering not because we do not want,
but because we (me, is more appropriate) are lazy.


Also, I am not sure that the interface should include things sort of

+	if ((addr_type & (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK |
+			IPV6_ADDR_MULTICAST)) != 0 ||
+			addr_type == IPV6_ADDR_ANY)

For kernel all they are direct routes, if the application wants to apply
some policy not formulated in terms of filters for RTM_GETROUTE, let it
to filter itself. Moreover, I used to emphasize that user of rtnetlink
should not believe to reliability of kernel filtering. It is just necessary
measure to guarantee that a new application, which is aware of a new
attribute, will behave correctly with older kernels, which are not aware
of this attribute. Not a requirement, of course.

Anyway, if you want to apply such specific policy, you can add a flag
to rtm_flags, which would say: RTM_F_OFFICIALLY_PREFIX and base filtering
on this flag, when it is given.

Alexey
