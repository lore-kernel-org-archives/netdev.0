From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH 1/1] net/ipv6: add sysctl option accept_ra_min_hop_limit
Date: Mon, 18 Jan 2016 17:33:47 +0900
Message-ID: <569CA36B.8080905@miraclelinux.com>
References: <1451896664-14271-1-git-send-email-machida.yuki@jp.fujitsu.com>
 <568B9836.1000202@miraclelinux.com> <5698BAF0.7060709@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Hangbin Liu <liuhangbin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"YOSHIFUJI Hideaki (USAGI Project)" <yoshfuji@linux-ipv6.org>
To: Yuki Machida <machida.yuki@jp.fujitsu.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36160 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753778AbcARIdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 03:33:51 -0500
Received: by mail-pf0-f171.google.com with SMTP id n128so154257599pfn.3
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 00:33:51 -0800 (PST)
In-Reply-To: <5698BAF0.7060709@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Yuki Machida wrote:
> Hi, Yoshifuji-san
> 
> It is currently under investigation.
> It takes still time.
> 
> Futher comment below.
> 
> On 2016年01月05日 19:17, YOSHIFUJI Hideaki wrote:
>> Hi, Machida-san.
>>
>> Yuki Machida wrote:
>>> Please apply the following patch to v4.1.x.
>>>
>>> By ommit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface")
>>
>> s/ommit/commit/
> I will correct this typo.
> 
>>
>> Futher comment below.
>>
>> :
>>> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
>>> Acked-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
>>> Signed-off-by: David S. Miller <davem@davemloft.net>
>>> ---
>>>   Documentation/networking/ip-sysctl.txt |  8 ++++++++
>>>   include/linux/ipv6.h                   |  1 +
>>>   include/uapi/linux/ipv6.h              |  1 +
>>>   net/ipv6/addrconf.c                    | 10 ++++++++++
>>>   net/ipv6/ndisc.c                       | 16 +++++++---------
>>>   5 files changed, 27 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
>>> index 071fb18..07fad3d 100644
>> :
>>> --- a/include/uapi/linux/ipv6.h
>>> +++ b/include/uapi/linux/ipv6.h
>>> @@ -171,6 +171,7 @@ enum {
>>>   	DEVCONF_USE_OPTIMISTIC,
>>>   	DEVCONF_ACCEPT_RA_MTU,
>>>   	DEVCONF_STABLE_SECRET,
>>
>> You have to add a hole for DEVCONF_USE_OIF_ADDRS_ONLY.
> 
> For addition a hole of DEVCONF_USE_OIF_ADDRS_ONLY,
> It needs following two patches.
> commit 9131f3de24db4dc12199aede7d931e6703e97f3b
> commit 3985e8a3611a93bb36789f65db862e5700aab65e
> 
> When It apply two patches to 4.1.15,
> It doesn't conform to RFC 2460 and RFC 4443.
> (I used IPv6 Ready Logo Core Conformance Test.)
> I am looking for a patch for fix.

You do not have to implement that interface if you
do not need.  You just have to reserve that number
to maintain binary compatibility:
   :
   __DEVCONF_USE_OIF_ADDRS_ONLY,	/* not implemented */
   DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
   DEVCONF_MAX

This is because those enums in include/"uapi"/linux/ipv6.h
are exported to userspace.

> 
>> --yoshfuji
>>
>>> +	DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
>>>   	DEVCONF_MAX
>>>   };
>>>   
>>

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
