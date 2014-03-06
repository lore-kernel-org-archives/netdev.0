From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/2] 6lowpan: reassembly: fix return of init
 function
Date: Thu, 06 Mar 2014 17:30:38 +0400
Message-ID: <5318787E.9000105@cogentembedded.com>
References: <1394052211-6976-1-git-send-email-alex.aring@gmail.com> <1394052211-6976-2-git-send-email-alex.aring@gmail.com> <53179F64.4060501@cogentembedded.com> <20140306054437.GA13676@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:60130 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbaCFNag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 08:30:36 -0500
Received: by mail-lb0-f175.google.com with SMTP id w7so1721966lbi.20
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 05:30:35 -0800 (PST)
In-Reply-To: <20140306054437.GA13676@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06-03-2014 9:44, Alexander Aring wrote:

>>> This patch adds a missing return after fragmentation init. Otherwise we
>>> register a sysctl interface and deregister it afterwards which makes no
>>> sense.

>>> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
>>> ---
>>>   net/ieee802154/reassembly.c | 2 ++
>>>   1 file changed, 2 insertions(+)
>>
>>> diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
>>> index 4511fc2..59db7b5 100644
>>> --- a/net/ieee802154/reassembly.c
>>> +++ b/net/ieee802154/reassembly.c
>>> @@ -550,6 +550,8 @@ int __init lowpan_net_frag_init(void)
>>>   	lowpan_frags.frag_expire = lowpan_frag_expire;
>>>   	lowpan_frags.secret_interval = 10 * 60 * HZ;
>>>   	inet_frags_init(&lowpan_frags);
>>> +
>>> +	return 0;

>>     Perhaps 'goto out' for "consistency" with the code above? (I don't know
>> why they used "goto out' in the first place.)

> ok, thanks, I will remove the "goto out" and will replace it with a
> "return 0" if you are fine with that.

    You can't replace it with "return 0", only with "return ret".

> - Alex

WBR, Sergei
