From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 1/3] [IPV6]: Restore semantics of Routing Header processing.
Date: Mon, 09 Jul 2007 21:27:35 -0400
Message-ID: <4692E087.8080908@hp.com>
References: <20070618.150423.46608800.yoshfuji@linux-ipv6.org>	<4676CBFD.1040901@hp.com> <20070709.143250.132417671.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:34041 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756725AbXGJBx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 21:53:28 -0400
In-Reply-To: <20070709.143250.132417671.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Mon, 18 Jun 2007 14:16:29 -0400
>=20
>> YOSHIFUJI Hideaki / =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=
=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD wrote:
>>>  					 IPSTATS_MIB_INHDRERRORS);
>>> @@ -465,6 +440,8 @@ looped_back:
>>>  		break;
>>>  #ifdef CONFIG_IPV6_MIP6
>>>  	case IPV6_SRCRT_TYPE_2:
>>> +		if (accept_source_route < 0)
>>> +			goto unknown_rh;
>>>  		/* Silently discard invalid RTH type 2 */
>>>  		if (hdr->hdrlen !=3D 2 || hdr->segments_left !=3D 1) {
>>>  			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
>> Do we really want to do this.  The IPv6 working group is bending ove=
r backwards
>> in it's attempt to _not_ break MIPv6 while deprecating RH0.  The abi=
lity to "break"
>> MIPv6 by disable RH2 without disabling the rest of MIP seems a "bad =
thing" to me.
>=20
> He's just preserving the intended logic of the sysctl, which by
> default does allow RT2 and thus keeps MIPV6 working, so I see no
> reason to be alarmed by this part of the patch.
>=20

Yes, but the addition of the sysctl was an overreaction.  Type 2
routing header was never a threat and the capability to disable it
is equivalent to capability of disabling Destionation Option Header
or any other extension IPv6 extension header.

Additionally, the following text is not going through the working
group:

4.2. Firewall Policy


   Blocking all IPv6 packets which carry Routing Headers (rather than
   specifically blocking type 0, and permitting other types) has very
   serious implications for the future development of IPv6.  If even a
   small percentage of deployed firewalls block other types of routing
   headers by default, it will become impossible in practice to extend
   IPv6 routing headers.  For example, Mobile IPv6 [RFC3775] relies upo=
n
   a type-2 RH; wide-scale, indescriminate blocking of Routing Headers
   will make Mobile IPv6 undeployable.

   Firewall policy intended to protect against packets containing RH0
   MUST NOT simply filter all traffic with a routing header; it must be
   possible to disable forwarding of type 0 traffic without blocking
   other types of routing headers.  In addition, the default
   configuration MUST permit forwarding of traffic using a RH other tha=
n
   0.

I know that they are applying to this to firewalls, but what we are
doing is providing a really simple nob, not even a firewall rule, that
can just disable RH type 2.

Just seems wrong to me.

-vlad
