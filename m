From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH v3] ipv6: Fix protocol resubmission
Date: Wed, 10 Jun 2015 10:53:32 -0500
Message-ID: <55785D7C.7080505@akamai.com>
References: <1433779259-14328-1-git-send-email-johunt@akamai.com>	<20150608.121601.1357405469784892473.davem@davemloft.net> <m2mw08kx7b.wl@gmail.com> <55783A1B.3070207@akamai.com> <557854BB.1090605@linux-ipv6.org> <55785687.90601@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	tom@herbertland.com
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Hajime Tazaki <thehajime@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:58691 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966174AbbFJPxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 11:53:34 -0400
In-Reply-To: <55785687.90601@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 06/10/2015 10:23 AM, Josh Hunt wrote:
> On 06/10/2015 10:16 AM, YOSHIFUJI Hideaki wrote:
>> Hi,
>>
>> Josh Hunt wrote:
>>>
>>> Hajime
>>>
>>> Thanks for the report. I mentioned in an earlier post this might be a
>>> problem.
>>>
>>> Dave, what if we restore the old behavior, but add a new label to
>>> handle the case where the decapsulating protocol returns the nexthdr
>>> value? Allowing for migration over to this method over time. I've
>>> pasted in a patch doing so below.
>>
>> I think it is insufficient because IPv6 stack already uses
>> positive value, 0 and negative values.
>>
>
> Where does it use a negative value?
>
> ret is only checked to be > or == to 0. I don't see any checks or code
> handling a return value of < 0 prior to my patch.
>
> If something does return a negative value should it since nothing
> happens with it?

Looking at the code again, I guess we don't increment
IPSTATS_MIB_INDELIVERS if we get a negative return value prior to my patch.

If so, then I guess we have to fix this in the udp path like you were 
suggesting. I will look at this and propose a patch to revert my 
original change and update the v6 udp code.

Josh
