From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store
 multicast entries
Date: Thu, 15 Dec 2016 09:32:45 -0800
Message-ID: <be3b69b7-b6a3-a939-cf77-c62e5a1fe719@gmail.com>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
 <87r35db35m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAMr9Lbp5eCg1oyWGN+uiDEcF0VZuKUi87FH6JYTGj6pL82R+Mw@mail.gmail.com>
 <48ff1136-dd8f-7704-a512-c23b27989bf8@gmail.com>
 <20161212190915.GA8885@lunn.ch>
 <CAMr9LbqyvrRYe_m34Ufzxkf2Vef3LbMQiuoiwVX0mK=hW6euyA@mail.gmail.com>
 <20161213150948.GD20323@lunn.ch>
 <CABHmqqB-6-L124hrAjNxd4kO3zYp9R=RM1X6PXyuQW6Hapiv4g@mail.gmail.com>
 <20161214104614.GD27370@lunn.ch>
 <CABHmqqDpiN2kwkTgrM8Qu8EEx3Sjk2yVBy8QQAJppGfJ6-MV5Q@mail.gmail.com>
 <87eg19hzw1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Volodymyr Bendiuga <valdr.linuxnext@gmail.com>,
        netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>,
        John Crispin <john@phrozen.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33073 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753972AbcLORdR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 12:33:17 -0500
Received: by mail-pf0-f193.google.com with SMTP id 144so3175955pfv.0
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 09:32:48 -0800 (PST)
In-Reply-To: <87eg19hzw1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2016 09:21 AM, Vivien Didelot wrote:
> Hi Volodymyr,
> 
> Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com> writes:
> 
>> Hi Andrew,
>>
>> I have tested the approach you wrote in previous mails, the one
>> with setting next.mac to address we are looking for -1. It seems
>> to be as slow as the original implementation, unfortunately.
> 
> Hum, that is what I was expecting... The ATU GetNext operation
> (alongside an ether_addr_equal() call) should be quite fast.
> 
>> We use 6097 and 6352 chips, and both of them can not do any port
>> filtering in hardware for fdb dump operation. Seems like they would
>> benefit from cache. But I am not sure about other switches.
>>
>> Does anyone know about such feature in other switches?
> 
> Marvell switches cannot filter ATU entries for a specific port, they
> contain a port vector.
> 
> I guess Florian might answer for Broadcom switches, and John might
> answer for Qualcomm switches.

For Broadcom switches, we use the ARL search and then apply software
filtering to discard entries that are not for the target port bridge fdb
show was called with.

> 
> In all cases *if caching is really needed*, I think it won't hurt to do
> it in DSA core even if a switch support FDB dump operations on a
> per-port basis, as Andrew mentioned.

Agreed, and there does not appear to be any need to new dsa_switch_ops
operations to be introduced?
-- 
Florian
