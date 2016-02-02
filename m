From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Re: [PATCH 1/1] net/ipv6: add sysctl option accept_ra_min_hop_limit
Date: Tue, 2 Feb 2016 17:49:25 +0900
Message-ID: <56B06D95.4010602@jp.fujitsu.com>
References: <1451896664-14271-1-git-send-email-machida.yuki@jp.fujitsu.com>
 <568B9836.1000202@miraclelinux.com> <5698BAF0.7060709@jp.fujitsu.com>
 <569CA36B.8080905@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: Hangbin Liu <liuhangbin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	netdev@vger.kernel.org,
	"YOSHIFUJI Hideaki (USAGI Project)" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm02.jp.fujitsu.com ([202.219.69.169]:23933 "EHLO
	mgwkm02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbcBBItd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 03:49:33 -0500
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 16228AC020D
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 17:49:26 +0900 (JST)
In-Reply-To: <569CA36B.8080905@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yoshifuji-san.

On 2016年01月18日 17:33, YOSHIFUJI Hideaki wrote:
> Hi,
> 
> Yuki Machida wrote:
>> Hi, Yoshifuji-san
>>
>> It is currently under investigation.
>> It takes still time.
>>
>> Futher comment below.
>>
>> On 2016年01月05日 19:17, YOSHIFUJI Hideaki wrote:
>>> Hi, Machida-san.
>>>
>>> Yuki Machida wrote:
>>>> Please apply the following patch to v4.1.x.
>>>>
>>>> By ommit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface")
>>>
>>> s/ommit/commit/
>> I will correct this typo.
>>
>>>
>>> Futher comment below.
>>>
>>> :
>>>> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
>>>> Acked-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
>>>> Signed-off-by: David S. Miller <davem@davemloft.net>
>>>> ---
>>>>    Documentation/networking/ip-sysctl.txt |  8 ++++++++
>>>>    include/linux/ipv6.h                   |  1 +
>>>>    include/uapi/linux/ipv6.h              |  1 +
>>>>    net/ipv6/addrconf.c                    | 10 ++++++++++
>>>>    net/ipv6/ndisc.c                       | 16 +++++++---------
>>>>    5 files changed, 27 insertions(+), 9 deletions(-)
>>>>
>>>> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
>>>> index 071fb18..07fad3d 100644
>>> :
>>>> --- a/include/uapi/linux/ipv6.h
>>>> +++ b/include/uapi/linux/ipv6.h
>>>> @@ -171,6 +171,7 @@ enum {
>>>>    	DEVCONF_USE_OPTIMISTIC,
>>>>    	DEVCONF_ACCEPT_RA_MTU,
>>>>    	DEVCONF_STABLE_SECRET,
>>>
>>> You have to add a hole for DEVCONF_USE_OIF_ADDRS_ONLY.
>>
>> For addition a hole of DEVCONF_USE_OIF_ADDRS_ONLY,
>> It needs following two patches.
>> commit 9131f3de24db4dc12199aede7d931e6703e97f3b
>> commit 3985e8a3611a93bb36789f65db862e5700aab65e
>>
>> When It apply two patches to 4.1.15,
>> It doesn't conform to RFC 2460 and RFC 4443.
>> (I used IPv6 Ready Logo Core Conformance Test.)
>> I am looking for a patch for fix.
It doesn't need these patches to solve this problem.

> 
> You do not have to implement that interface if you
> do not need.  You just have to reserve that number
> to maintain binary compatibility:
>     :
>     __DEVCONF_USE_OIF_ADDRS_ONLY,	/* not implemented */
>     DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
>     DEVCONF_MAX
> 
> This is because those enums in include/"uapi"/linux/ipv6.h
> are exported to userspace.
Thank you for your advice.
I will resend a patch of V2.

>>
>>> --yoshfuji
>>>
>>>> +	DEVCONF_ACCEPT_RA_MIN_HOP_LIMIT,
>>>>    	DEVCONF_MAX
>>>>    };
>>>>    
>>>
> 
