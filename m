From: Ben Greear <greearb@candelatech.com>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Wed, 30 Mar 2016 09:52:21 -0700
Message-ID: <56FC0445.6010200@candelatech.com>
References: <56F9941A.3080501@candelatech.com>
 <56FAAA6D.3070806@candelatech.com> <1459329252.2055.1.camel@sipsolutions.net>
 <20160330.123821.328761526754742195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	tgraf@suug.ch
To: David Miller <davem@davemloft.net>, johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:44321 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932960AbcC3QwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 12:52:23 -0400
In-Reply-To: <20160330.123821.328761526754742195.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/30/2016 09:38 AM, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Wed, 30 Mar 2016 11:14:12 +0200
>
>> On Tue, 2016-03-29 at 09:16 -0700, Ben Greear wrote:
>>> Looks like rhashtable has too much policy in it to properly deal with
>>> cases where there are too many hash collisions, so I am going to work
>>> on reverting it's use in mac80211.
>>
>> I'm not really all that happy with that approach - can't we fix the
>> rhashtable? It's a pretty rare corner case that many keys really are
>> identical and no kind of hash algorithm, but it seems much better to
>> still deal with it than to remove the rhashtable usage and go back to
>> hand-rolling something.
>
> Yeah reverting seems like a really idiotic way to deal with the issue.
>

If someone can fix rhashtable, then great.
I read some earlier comments [1] back when someone else reported
similar problems, and the comments seemed to indicate that rhashtable was
broken in this manner on purpose to protect against hashing attacks.

If you are baking in this type of policy to what should be a basic
data-type, then it is not useful for how it is being used in
the mac80211 stack.

[1]  http://lkml.iu.edu/hypermail/linux/kernel/1512.2/01681.html

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
