From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Fri, 06 Jun 2003 22:31:01 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030606223057.41ac1c9d.nakam@linux-ipv6.org>
References: <20030424132559.GA15894@morphine.tml.hut.fi>
	<Pine.LNX.4.44.0305301712300.3584-200000@rhea.tcs.hut.fi>
	<20030531.000319.114704530.yoshfuji@linux-ipv6.org>
	<20030605.191224.68706097.yoshfuji@linux-ipv6.org>
	<20030606143844.0604c306.nakam@linux-ipv6.org>
	<3EE0779B.9080300@tml.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>,
   vnuorval@tcs.hut.fi, davem@redhat.com, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi,
   lpetande@morphine.tml.hut.fi, jagana@us.ibm.com, kumarkr@us.ibm.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Henrik Petander <lpetande@tml.hut.fi>
In-Reply-To: <3EE0779B.9080300@tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Henrik,

On Fri, 06 Jun 2003 14:14:35 +0300
Henrik Petander <lpetande@tml.hut.fi> wrote:

> I like your idea, as it allows a high level of flexibility in use of
> mipv6  with flows through the definition of policies. This is the way I
> would also do mipv6 extension header addition with xfrm.

Thanks.


> However, if you insert mipv6 policies into xfrm, you need to take care
> of the interactions between ipsec and mipv6 policies. The system needs
> to cope with data flows to which both ipsec and mipv6 should be applied.
> As a result of this the logic of the xfrm lookups probably needs some
> changes to return both the matching ipsec and mipv6 policies. How have
> you planned to solve this problem?

We don't think we have to change the logic handling policy with
the reason because we can treat MIPv6 policy just like IPsec.

When we want to apply both MIPv6 and IPsec to the same target,
we need one policy that has two or more of templates(e.g. one is
MIPv6's template and the other is IPsec's). 

Regarding above case, however, we have a problem like below:

draft(9.3.1 in draft-ietf-mobileip-ipv6-22) says,

  When attempting to verify AH authentication data in a packet that
  contains a Home Address option, the receiving node MUST calculate
  the AH authentication data as if the following were true: The Home
  Address option contains the care-of address, and the source IPv6
  address field of the IPv6 header contains the home address.

Because xfrm decides to call dst_output in the order of templates,
at first we had no idea which is the former template, MIPv6 or IPsec(Home
Address Option or AH).

Then we discussed about that with our IPsec guys and now we guess we have
an idea to use xfrm6_clear_mutable_options() to re-replace address for
calculating for AH when calling ah6_output().

Anyway, I think this is not specialized matter of xfrm. (Did you also point
this, Henrik?) Or, could you have any idea?


> BTW, feel free to use relevant parts of my code for the output
> functionality to speed up the work. After your code is ready we can look
> at which approach is better suited for implementing the kernel support
> and get a working kernel infrastructure for mipv6 into 2.6 kernels.

Thank you for your kindness. Of course I agree with you.

Regards,

-- 
Masahide NAKAMURA
