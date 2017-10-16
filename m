From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 5/6] rtnetlink: check DO_SETLINK_NOTIFY correctly in
 do_setlink
Date: Mon, 16 Oct 2017 14:20:27 +0200
Message-ID: <a783ef9d-e66c-b906-fcfd-4da5d560af9d@6wind.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
 <d7713874f0ad1c19b640eaae98f0d554d1743a4c.1508062280.git.lucien.xin@gmail.com>
 <e240a6572c8e495eb2da15bd6178604cdfde08ba.1508062280.git.lucien.xin@gmail.com>
 <b4125c6cf42d4d028a9c04f4989627ac1eb83257.1508062280.git.lucien.xin@gmail.com>
 <784f477a1f9e8b9a5ec7bbe9e1dff1dcdfd5553b.1508062280.git.lucien.xin@gmail.com>
 <22c0aefe18d4451166c5f12714d8520346a63f2b.1508062280.git.lucien.xin@gmail.com>
 <f3e88287-e2b8-06a9-a139-7a528749ef9e@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: David Ahern <dsahern@gmail.com>, Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:55893 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752774AbdJPMUa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 08:20:30 -0400
Received: by mail-wm0-f43.google.com with SMTP id u138so2657536wmu.4
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 05:20:30 -0700 (PDT)
In-Reply-To: <f3e88287-e2b8-06a9-a139-7a528749ef9e@gmail.com>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/10/2017 à 03:17, David Ahern a écrit :
> [ cc'ed Nicolas ]
> 
> On 10/15/17 4:13 AM, Xin Long wrote:
>> The check 'status & DO_SETLINK_NOTIFY' in do_setlink doesn't really
>> work after status & DO_SETLINK_MODIFIED, as:
>>
>>   DO_SETLINK_MODIFIED 0x1
>>   DO_SETLINK_NOTIFY 0x3
>>
>> Considering that notifications are suppposed to be sent only when
>> status have the flag DO_SETLINK_NOTIFY, the right check would be:
>>
>>   (status & DO_SETLINK_NOTIFY) == DO_SETLINK_NOTIFY
>>
>> This would avoid lots of duplicated notifications when setting some
>> properties of a link.
>>
>> Fixes: ba9989069f4e ("rtnl/do_setlink(): notify when a netdev is modified")
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
Good catch, thank you.

Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
