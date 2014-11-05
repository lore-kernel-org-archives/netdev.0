From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] ipv6: mld: fix add_grhead skb_over_panic for devs
 with large MTUs
Date: Wed, 05 Nov 2014 13:09:13 +0100
Message-ID: <545A1369.2040309@redhat.com>
References: <1415149113-32668-1-git-send-email-dborkman@redhat.com> <1415149616.30247.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, lw1a2.jing@gmail.com, fw@strlen.de,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	David L Stevens <david.stevens@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51220 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbaKEMJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 07:09:27 -0500
In-Reply-To: <1415149616.30247.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2014 02:06 AM, Eric Dumazet wrote:
> On Wed, 2014-11-05 at 01:58 +0100, Daniel Borkmann wrote:
>> It has been reported that generating an MLD listener report on
>> devices with large MTUs (e.g. 9000) and a high number of IPv6
>> addresses can trigger a skb_over_panic():
>>
[...]
>>
>> Reported-by: lw1a2.jing@gmail.com
>> Fixes: 72e09ad107e7 ("ipv6: avoid high order allocations")
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: David L Stevens <david.stevens@oracle.com>
>> ---
>>   In skb_nofrag_tailroom(), we could actually omit the !skb->dev check,
>>   but I leave that rather as a possible cleanup item for net-next.

Thanks for your feedback!

> Hmm... we have a proliferation of such things.
>
> Could you take a look at sk_stream_alloc_skb(), skb->reserved_tailroom,
> and skb_availroom() ?

Ok, here would be a proposal based on skb_availroom():

   http://patchwork.ozlabs.org/patch/406959/

Thanks,
Daniel
