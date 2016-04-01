From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Re: Section 4 No. 9,10 Failed was occurred by IPv6 Ready Logo
 Conformance Test
Date: Fri, 1 Apr 2016 17:00:16 +0900
Message-ID: <56FE2A90.8080300@jp.fujitsu.com>
References: <56FE23C4.2000706@jp.fujitsu.com> <56FE26BE.2060209@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
To: Rongqing Li <rongqing.li@windriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:34044 "EHLO
	mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbcDAIAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 04:00:20 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 6D6BEAC049E
	for <netdev@vger.kernel.org>; Fri,  1 Apr 2016 17:00:16 +0900 (JST)
In-Reply-To: <56FE26BE.2060209@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roy,

Thank you for your advice.
I am very glad.

Futher comment below.

On 2016年04月01日 16:43, Rongqing Li wrote:
> 
> 
> On 2016年04月01日 15:31, Yuki Machida wrote:
>> Hi all,
>>
>> I tested 4.6-rc1 by IPv6 Ready Logo Core Conformance Test.
>> 4.6-rc1 has some FAILs in Section 4 (RFC 1981: Path MTU Discovery for IP version 6).
>> I conformed that it was PASSed in 3.14.28 and it was FAILed in 4.1.17.
>> I will find a patch between 3.14 and 4.1.
>>
>> IPv6 Ready Logo
>> https://www.ipv6ready.org/
>> TAHI Project
>> http://www.tahi.org/
>>
>> I ran the IPv6 Ready Logo Core Conformance Test on Intel D510MO (Atom D510).
>> It is using userland build with yocto project.
>>
>> Test Environment
>> Test Specification          : 4.0.6
>> Tool Version                : REL_3_3_2
>> Test Program Version        : V6LC_5_0_0
>> Target Device               : Intel D510MO (Atom D510)
>>
>> List of FAILs
>>
>> Section 4: RFC 1981 - Path MTU Discovery for IPv6
>> - Test v6LC.4.1.6: Receiving MTU Below IPv6 Minimum Link MTU
>>     - No. 9 Part A: MTU equal to 56
>>     - No.10 Part B: MTU equal to 1279
>>
> 
> apply this one
> 
> commit 8013d1d7eafb0589ca766db6b74026f76b7f5cb4
> Author: Hangbin Liu <liuhangbin@gmail.com>
> Date:   Thu Jul 30 14:28:42 2015 +0800
> 
>      net/ipv6: add sysctl option accept_ra_min_hop_limit
> 
>      Commit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface")
>      disabled accept hop limit from RA if it is smaller than the current hop
>      limit for security stuff. But this behavior kind of break the RFC
> definition.
> 
>      RFC 4861, 6.3.4.  Processing Received Router Advertisements
>         A Router Advertisement field (e.g., Cur Hop Limit, Reachable Time,
>         and Retrans Timer) may contain a value denoting that it is
>         unspecified.  In such cases, the parameter should be ignored and the
>         host should continue using whatever value it is already using.
> 
>         If the received Cur Hop Limit value is non-zero, the host SHOULD set
>         its CurHopLimit variable to the received value.
> 
>      So add sysctl option accept_ra_min_hop_limit to let user choose the
> minimum
>      hop limit value they can accept from RA. And set default to 1 to
> meet RFC
>      standards.
> 
>      Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
>      Acked-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
>      Signed-off-by: David S. Miller <davem@davemloft.net>

I conformed that above patch has been applied at v4.3 in linux.git.

% git tag --contains=8013d1d7eafb0589ca766db6b74026f76b7f5cb4 | head
v4.3
v4.3-rc1
v4.3-rc2
v4.3-rc3
v4.3-rc4
v4.3-rc5
v4.3-rc6
v4.3-rc7
v4.4
v4.4-rc1

> 
> 
> 
> 
> 
> and revert the below one, the TAHI should be updated
> 
> commit 9d289715eb5c252ae15bd547cb252ca547a3c4f2
> Author: Hagen Paul Pfeifer <hagen@jauu.net>
> Date: Thu Jan 15 22:34:25 2015 +0100
> 
>      ipv6: stop sending PTB packets for MTU < 1280
> 
>      Reduce the attack vector and stop generating IPv6 Fragment Header for
>      paths with an MTU smaller than the minimum required IPv6 MTU
>      size (1280 byte) - called atomic fragments.
> 
>      See IETF I-D "Deprecating the Generation of IPv6 Atomic Fragments" [1]
>      for more information and how this "feature" can be misused.
> 
>      [1]
> https://tools.ietf.org/html/draft-ietf-6man-deprecate-atomfrag-generation-00
> 
>      Signed-off-by: Fernando Gont <fgont@si6networks.com>
>      Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
>      Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>      Signed-off-by: David S. Miller <davem@davemloft.net>

I will try.

> 
> 
> 
> -Roy
> 
> 
> 
> 
>> Regards,
>> Yuki Machida
>>
> 
