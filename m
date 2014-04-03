From: Albert Krenz <albert.krenz87@googlemail.com>
Subject: Re: Cannot delete entries from bridge fdb
Date: Thu, 3 Apr 2014 08:30:57 +0200
Message-ID: <CAPRaSD6XofnCtzb3x6tDpe4gOCJKbdPapAdD2tAb_xbqW=qyUg@mail.gmail.com>
References: <CAPRaSD7v2S2Hy+4vJytX8Q1L42X_qJryDYRGmpauJfjqxsywwQ@mail.gmail.com>
	<1396457191.2215.45.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:40512 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161716AbaDCGa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 02:30:58 -0400
Received: by mail-qa0-f54.google.com with SMTP id w8so1209830qac.41
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 23:30:57 -0700 (PDT)
In-Reply-To: <1396457191.2215.45.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Deleting with the value 'master' worked! Thank you very much.

greetings
Albert Krenz

2014-04-02 18:46 GMT+02:00 Toshiaki Makita <toshiaki.makita1@gmail.com>:
> On Wed, 2014-04-02 at 11:25 +0200, Albert Krenz wrote:
>> Hello everyone,
>> i have a question concerning the forwarding database (fdb) of the
>> bridges. I am using:
>> - Ubuntu 13.10
>> - kernel 3.11.0 from ubuntu repos
>> - bridge utility 0.0 from iproute2 package
>> - bridge-utils 1.5
>>
>> I have 3 applications, each one creating a tap (tap0 - tap2) which i
>> add to the bridge br0. Two Applications are receiving Frames (app0 and
>> app1) and the third one (app2) sends one Frame every second to app0.
>> SRC and DST MAC are different from the tap MAC's. App0 sends an answer
>> to app2 and the bridge adds an entry to his fdb with the MAC of app0
>> on tap0.
>>
>> Now i wanted to delete this entry which does not work. RTNETLINK tells
>> me there is no file or directory. See the following example:
>>
>> root@mypc:~# bridge fdb show dev tap0
>> 33:33:00:00:00:01 self permanent
>> 01:00:5E:00:00:01 self permanent
>> 40:EC:F8:03:A7:B5 vlan 0
>>               << i want to delete this one
>> 9A:0D:06:68:5D:75 vlan 0 permanent
>>          << MAC of tap0
>> root@mypc:~# bridge fdb del 40:EC:F8:03:A7:B5 vlan0 dev tap0
>> RTNETLINK answers: No such file or directory
>
> Please try this command.
> # bridge fdb del 40:EC:F8:03:A7:B5 dev tap0 master
>
> Thanks,
> Toshiaki Makita
>
>>
>> If i add a random entry i can delete it without any problem.
>>
>> root@mypc:~# bridge fdb add 40:EC:F8:03:A7:FF vlan0 dev tap0
>> root@mypc:~# bridge fdb del 40:EC:F8:03:A7:FF vlan0 dev tap0
>>                 << this works
>>
>> Is there another syntax to delete entries which the bridge has added
>> by himself? Or is it not possible to delete entries which you haven't
>> added by hand?
>>
>> greetings
>> Albert Krenz
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
