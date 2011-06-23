From: Marius Kotsbak <marius.kotsbak@gmail.com>
Subject: Re: [PATCH] net/usb: kalmia: Various fixes for better support of
 non-x86 architectures.
Date: Thu, 23 Jun 2011 22:56:24 +0200
Message-ID: <4E03A878.2070105@gmail.com>
References: <20110619.155755.1854488306547854947.davem@davemloft.net> <1308756376-9920-1-git-send-email-marius@kotsbak.com> <4E03198A.2060600@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, "Marius B. Kotsbak" <marius@kotsbak.com>
To: Sergei Shtylyov <sshtylyov@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46531 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933706Ab1FWU4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 16:56:30 -0400
In-Reply-To: <4E03198A.2060600@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Den 23. juni 2011 12:46, skrev Sergei Shtylyov:
> Hello.
>
> On 22-06-2011 19:26, Marius B. Kotsbak wrote:
>
>> -Support for big endian.
>> -Do not use USB buffers at the stack.
>> -Safer/more efficient code for local constants.
>
>> Signed-off-by: Marius B. Kotsbak<marius@kotsbak.com>
>> ---
>>   drivers/net/usb/kalmia.c |   40 
>> ++++++++++++++++++++++++----------------
>>   1 files changed, 24 insertions(+), 16 deletions(-)
>
>
>> -    char receive_buf[28];
>> +    const static int buflen = 28;
>
>    Why declare it at all, when it's used only once?
>
>> +    char *usb_buf;
>>       int status;
>>
>> -    status = kalmia_send_init_packet(dev, init_msg_1, 
>> sizeof(init_msg_1)
>> -        / sizeof(init_msg_1[0]), receive_buf, 24);
>> +    usb_buf = kmalloc(buflen, GFP_DMA | GFP_KERNEL);
>> +    if (!usb_buf)
>> +        return -ENOMEM;
>> +
>> +    memcpy(usb_buf, init_msg_1, 12);
>
>    s/12/sizeof(init_msg_1)/
>
>> +    status = kalmia_send_init_packet(dev, usb_buf, sizeof(init_msg_1)
>> +        / sizeof(init_msg_1[0]), usb_buf, 24);
>
>    There's ARRAY_SIZE() macro to replace:
>
> sizeof(init_msg_1) / sizeof(init_msg_1[0])
>
>    and why not use just sizeof(init_msg_1)?
>
>>       if (status != 0)
>>           return status;
>>
>> -    status = kalmia_send_init_packet(dev, init_msg_2, 
>> sizeof(init_msg_2)
>> -        / sizeof(init_msg_2[0]), receive_buf, 28);
>> +    memcpy(usb_buf, init_msg_2, 12);
>
>    s/12/sizeof(init_msg_2)/
>
>> +    status = kalmia_send_init_packet(dev, usb_buf, sizeof(init_msg_2)
>> +        / sizeof(init_msg_2[0]), usb_buf, 28);
>
>    The same comment here about:
>
> sizeof(init_msg_2) / sizeof(init_msg_2[0])
>

Thanks for the tips. I know some parts of the code are a bit ugly, but 
the primary goal was to get it working despite the quirky state of the 
current modem firmware. I have noted it for later fixing.

--
Marius

