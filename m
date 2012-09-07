From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] sctp: check dst validity after IPsec operations
Date: Fri, 07 Sep 2012 14:24:46 +0200
Message-ID: <5049E78E.6080908@6wind.com>
References: <1346953229-3825-1-git-send-email-nicolas.dichtel@6wind.com> <5048C984.3030306@gmail.com> <5048D219.4020001@6wind.com> <5048D774.3020008@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33121 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760537Ab2IGMYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 08:24:50 -0400
Received: by mail-ee0-f46.google.com with SMTP id c1so1146280eek.19
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2012 05:24:49 -0700 (PDT)
In-Reply-To: <5048D774.3020008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/09/2012 19:03, Vlad Yasevich a =E9crit :
> On 09/06/2012 12:40 PM, Nicolas Dichtel wrote:
>> Le 06/09/2012 18:04, Vlad Yasevich a =E9crit :
>>> On 09/06/2012 01:40 PM, Nicolas Dichtel wrote:
>>>> dst stored in struct sctp_transport needs to be recalculated when
>>>> ipsec policy
>>>> are updated. We use flow_cache_genid for that.
>>>>
>>>> For example, if a SCTP connection is established and then an IPsec
>>>> policy is
>>>> set, the old SCTP flow will not be updated and thus will not use t=
he new
>>>> IPsec policy.
>>>>
>>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>
>>> why doesn't this need to be done for TCP?  What makes SCTP special =
in
>>> this case?
>> Tests prove that the pb does not exist with TCP. I made the patch so=
me
>> times ago, I will look again deeply to find the difference.
>>
>
> TCP appears to cache the flowi and uses that to re-route the packet.
> However, re-route still seems predicated on dst_check()...
Yes ... but I don't find the difference. Re-route is not done immediate=
ly in=20
TCP, it takes few seconds.

>
>>>
>>> ip_queue_xmit does an __sk_dst_check() which is essentially what
>>> sctp_transport_dst_check() does.  That should determine if the
>>> currently cached
>>> route is valid or not.
>> The problem is that route will not be invalidated, because dst->chec=
k()
>> has no xfrm path so xfrm_dst_check() will never be called.
>>
>
> Shouldn't the cache be invalidated in this case?  If the cache is inv=
alidated,
> that should cause a new lookup.  If the cache isn't invalidated, then=
 any
> established connections that may now be impacted by the policy will n=
ot pick it up.
Yes, you're right. If I flush the cache manually (with the sysctl), rou=
te are=20
correctly updated.
I will send a new proposal.


Regards,
Nicolas
