From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Fri, 06 Jun 2003 14:38:49 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030606143844.0604c306.nakam@linux-ipv6.org>
References: <20030424132559.GA15894@morphine.tml.hut.fi>
	<Pine.LNX.4.44.0305301712300.3584-200000@rhea.tcs.hut.fi>
	<20030531.000319.114704530.yoshfuji@linux-ipv6.org>
	<20030605.191224.68706097.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>,
   vnuorval@tcs.hut.fi, davem@redhat.com, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi,
   lpetande@morphine.tml.hut.fi, jagana@us.ibm.com, kumarkr@us.ibm.com
In-Reply-To: <20030605.191224.68706097.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
I'm Nakamura, a member of USAGI.

On Thu, 05 Jun 2003 19:12:24 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Well, I won't hurry intorducing IPv6 policy routing just because of MIP6.
> The reason why I won't hurry is because I still believe it is not
> required for MIP6.  Nakamura, one of our member, will describe the details.
> It takes precedence over "limited" policy(?) routing to introcuce generic 
> policy routing.

As you know, we've been planning the MIPv6 design to use XFRM.
If we use MIPv6, we need some fix and extension to XFRM and it results to make XFRM
more generic.

On output processing, our design is like below:

  Through netlink/xfrm from userland, we have to set xfrm_policy and xfrm_state with
  something like ip command(or extended ip command).

  The xfrm_policy has two templates now:
  	- template handling Routing Header type 2(RT2)      ...(a)
  	- template handling Destination Options Header(DST) ...(b)

  And we have to add one address field(c) in xfrm_state for MIPv6.
  (Currently it is named mip6_state.addr.)

  Template-(a) finds a xfrm_state that points function like mip6_rthdr_output()
  to insert RT2 and replace dst address of IP header with specified address-(c).

  Also, template-(b) finds a xfrm_state that points function like mip6_destopt_output()
  to insert DST and replace src address of IP header with specified address-(c).

  Of course, both mip6_rthdr_output() and mip6_destopt_output() are callled as dst_output
  in XFRM world internally.

  For example, if two state is found, the packet will be append both RT2 and DST.
  We have tested that on our tree.

  In case of tunneling, We think we also make it to add a template and
  prepare a function for dst_output on XFRM world like above.
  (Maybe xfrm6_tunnel needs some fix to use MIPv6, as Henrik said.)

Could you give us comments?

BTW, I have read Henrik's patch(mip6-exthdr.patch) sent to netdev in other thread and I
feel that is simple code to implement MIPv6 and is clean one. Thanks, Henrik.
As he said, it is similar one to use XFRM like ours.
We know that the big difference between yours and ours is to modify either routing table or
XFRM.

Anyway, we'll show you our patch later.

Regards,

-- 
Masahide NAKAMURA
