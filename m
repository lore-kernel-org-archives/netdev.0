From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 3/7] gue: Add infrastructure for flags and options
Date: Mon, 3 Nov 2014 10:39:14 -0800
Message-ID: <CA+mtBx8QZn8M8mnU84w2+sc4bt98kf-_SuW0jz15qYNX21vCag@mail.gmail.com>
References: <1414882683-25484-1-git-send-email-therbert@google.com>
	<1414882683-25484-4-git-send-email-therbert@google.com>
	<20141103.121856.1307429117331581815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:58987 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbaKCSjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 13:39:15 -0500
Received: by mail-ig0-f170.google.com with SMTP id h15so5055087igd.3
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 10:39:15 -0800 (PST)
In-Reply-To: <20141103.121856.1307429117331581815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 3, 2014 at 9:18 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Sat,  1 Nov 2014 15:57:59 -0700
>
>> @@ -20,7 +20,16 @@ static size_t fou_encap_hlen(struct ip_tunnel_encap *e)
>>
>>  static size_t gue_encap_hlen(struct ip_tunnel_encap *e)
>>  {
>> -     return sizeof(struct udphdr) + sizeof(struct guehdr);
>> +     size_t len;
>> +     bool need_priv = false;
>> +
>> +     len = sizeof(struct udphdr) + sizeof(struct guehdr);
>> +
>> +     /* Add in lengths flags */
>> +
>> +     len += need_priv ? GUE_LEN_PRIV : 0;
>
> Add this need_priv logic in patch #6, not here.

I would rather keep it in this patch. This is adding the common
infrastructure to support private option field, remote checksum
offload is an instance that uses that.

Tom
