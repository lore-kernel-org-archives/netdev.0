From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Fri, 12 Dec 2014 09:35:45 -0500
Message-ID: <548AFD41.3010801@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>
To: Hubert Sokolowski <h.sokolowski@wit.edu.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:39095 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967493AbaLLOfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 09:35:55 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so7019716ieb.3
        for <netdev@vger.kernel.org>; Fri, 12 Dec 2014 06:35:55 -0800 (PST)
In-Reply-To: <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/14 08:36, Hubert Sokolowski wrote:
>> On 12/12/14 06:38, Hubert Sokolowski wrote:
>>>> On 12/11/14, 9:06 AM, Hubert Sokolowski wrote:
>>
>>> Please see how the ndo_dflt_fdb_add and del are called:
>>> 		if (dev->netdev_ops->ndo_fdb_add)
>>> 			err = dev->netdev_ops->ndo_fdb_add(ndm, tb, dev, addr,
>>> 							   vid,
>>> 							   nlh->nlmsg_flags);
>>> 		else
>>> 			err = ndo_dflt_fdb_add(ndm, tb, dev, addr, vid,
>>> 					       nlh->nlmsg_flags);
>>>
>>
>> Semantically add and dump are not the same.
>> Add adds a specific entry.
>> Dump not only dumps the fdb table but also the unicast and multicast
>> addresses.
> this is not true for 3.16 and before. Please see:
> http://lxr.free-electrons.com/source/net/core/rtnetlink.c?v=3.16#L2545
> It lets you fully manage the FDB table by overwriding fdb_add, del and dump
> in the same way.
>
 >
>
>>
>>
>>> As it was suggested by Ronen I can modify the patch so the dflt callback
>>> is always called for bridge devices if this is desirable. Either by calling
>>> it when following expression is true:
>>>       (dev->priv_flags & IFF_BRIDGE_PORT)
>>> or by modifying br_fdb_dump to call ndo_dflt_fdb_dump.
>>>
>>
>> Are you saying the above is going to work? You need to TEST please.
> yes, it works and it is not a rocket science :). we just need to agree
> on the approach to use.
>

I am happy if this solves wont break
any of the use cases Vlad made me test and make sure work.
When i said "test" - I mean run the testcases outlined in the
commit log; if those work i dont see what the issue is.

cheers,
jamal
