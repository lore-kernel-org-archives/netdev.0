From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH]
Date: Thu, 26 Sep 2013 17:44:13 +0200
Message-ID: <5244564D.5050504@redhat.com>
References: <1380204582-27144-1-git-send-email-nikolay@redhat.com>  <1380204582-27144-2-git-send-email-nikolay@redhat.com> <1380209227.3165.176.camel@edumazet-glaptop> <52445553.1030308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54256 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753363Ab3IZPrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 11:47:49 -0400
In-Reply-To: <52445553.1030308@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2013 05:40 PM, Nikolay Aleksandrov wrote:
> On 09/26/2013 05:27 PM, Eric Dumazet wrote:
>> On Thu, 2013-09-26 at 16:09 +0200, Nikolay Aleksandrov wrote:
>>> Factor out the code that extracts the ports from skb_flow_dissect and
>>> add a new function skb_flow_get_ports which can be re-used.
>>>
>>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>>> ---
>>> v2: new patch
>>> v3: fix a bug in skb_flow_dissect where thoff didn't have poff added by
>>>     modifying thoff directly in skb_flow_get_ports as it's done anyway.
>>>     Also add the necessary export symbol for skb_flow_get_ports.
>>> This seems like a good idea because there're other users that can re-use
>>> it later as well.
>>
>> Wait a minute.... existing code seems buggy.
>>
>> Daniel, any objection if I submit this fix ?
>>
>> (commit 8ed781668dd49b608f)
>>
> 1 question, I might be missing something but proto_ports_offset() gets the SPI
> with that 4 byte offset as is written in the comments, in every other case
> proto_ports_offset() is 0, so why would we want the SPI in the ->ports field ?
> And even then isn't it supposed to be 16 bits (2 bytes) and not 4, since we need
> to pass over "next header" (8 bits) and length (8 bits) ?
> 
Nevermind the second part, I forgot about the 16-bit 0 region :-)

> Thanks,
>  Nik
