From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/7] gue: Add infrastructure for flags and
 options
Date: Mon, 03 Nov 2014 15:12:48 -0500 (EST)
Message-ID: <20141103.151248.1183539988304355806.davem@davemloft.net>
References: <1414882683-25484-4-git-send-email-therbert@google.com>
	<20141103.121856.1307429117331581815.davem@davemloft.net>
	<CA+mtBx8QZn8M8mnU84w2+sc4bt98kf-_SuW0jz15qYNX21vCag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634AbaKCUMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 15:12:51 -0500
In-Reply-To: <CA+mtBx8QZn8M8mnU84w2+sc4bt98kf-_SuW0jz15qYNX21vCag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 3 Nov 2014 10:39:14 -0800

> On Mon, Nov 3, 2014 at 9:18 AM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <therbert@google.com>
>> Date: Sat,  1 Nov 2014 15:57:59 -0700
>>
>>> @@ -20,7 +20,16 @@ static size_t fou_encap_hlen(struct ip_tunnel_encap *e)
>>>
>>>  static size_t gue_encap_hlen(struct ip_tunnel_encap *e)
>>>  {
>>> -     return sizeof(struct udphdr) + sizeof(struct guehdr);
>>> +     size_t len;
>>> +     bool need_priv = false;
>>> +
>>> +     len = sizeof(struct udphdr) + sizeof(struct guehdr);
>>> +
>>> +     /* Add in lengths flags */
>>> +
>>> +     len += need_priv ? GUE_LEN_PRIV : 0;
>>
>> Add this need_priv logic in patch #6, not here.
> 
> I would rather keep it in this patch. This is adding the common
> infrastructure to support private option field, remote checksum
> offload is an instance that uses that.

Tom, it evaluates always to a constant boolean, and contextually makes
no sense to someone reviewing this change in isolation.

Please, as I have asked, put this in the patch where the logic
actually matters.
