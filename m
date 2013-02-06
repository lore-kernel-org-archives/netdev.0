From: jamal <j.hadi123@gmail.com>
Subject: Re: [RFC PATCH] xfrm: fix handling of XFRM policies mark and mask.
Date: Wed, 06 Feb 2013 08:14:44 -0500
Message-ID: <51125744.3030905@gmail.com>
References: <9E57ADA1-5770-47A8-8EBF-7FC262EEF1C7@ipflavors.com> <20130205081232.GF23291@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Romain KUNTZ <r.kuntz@ipflavors.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	herbert@gondor.apana.org.au,
	Emmanuel THIERRY <emmanuel.thierry@telecom-bretagne.eu>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:38493 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216Ab3BFNOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 08:14:48 -0500
In-Reply-To: <20130205081232.GF23291@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

On 13-02-05 03:12 AM, Steffen Klassert wrote:
>> For example, executing the below commands in that order succeed:
>>   ip -6 xfrm policy flush
>>   ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark 1 mask 0xffffffff
>>   ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out
> The policy with mark 1 is the first we find. The policy passes the
> mark check and if the flow matches the selectors, we use this policy.
>
>> But it fails in the reverse order:
>>   ip -6 xfrm policy flush
>>   ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out
>>   ip -6 xfrm policy add src fd00::1/128 dst fd00::2/128 dir out mark 1 mask 0xffffffff
>>   RTNETLINK answers: File exists
> With this scenario, we would find the policy with mark and mask 0 first.
> This policy passes the mark check too. So we would use this policy if the
> flow matches the selectors, but the flow asked for a policy with mark 1.

I think the intent Romain is expressing is reasonable and should resolved at
insertion time(xfrm_policy_insert()).
i.e even though the policy (such as mark=1) is inserted afterwards, at
insertion time if it proves it is more specific and not duplicate, it 
should be
inserted ahead of the mark=0.
The runtime check will work then.

cheers,
jamal
