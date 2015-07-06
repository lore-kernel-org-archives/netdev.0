From: Erik Kline <ek@google.com>
Subject: Re: [PATCH net-next] ipv6: sysctl to restrict candidate source addresses
Date: Mon, 6 Jul 2015 12:06:33 +0900
Message-ID: <CAAedzxqC3jeezcSnmM+PYJYT+oVFr6kZ1mX_xBFmMrsGFTH6VQ@mail.gmail.com>
References: <1435898941-9259-1-git-send-email-ek@google.com> <559633A6.9040403@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Lorenzo Colitti <lorenzo@google.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33980 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbbGFDGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2015 23:06:54 -0400
Received: by wifm2 with SMTP id m2so16906340wif.1
        for <netdev@vger.kernel.org>; Sun, 05 Jul 2015 20:06:52 -0700 (PDT)
In-Reply-To: <559633A6.9040403@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reworked with "use_oif_addr".

Thanks,
-Erik

On 3 July 2015 at 16:03, YOSHIFUJI Hideaki
<hideaki.yoshifuji@miraclelinux.com> wrote:
> Hi,
>
> Erik Kline wrote:
>> Per RFC 6724, section 4, "Candidate Source Addresses":
>>
>>     It is RECOMMENDED that the candidate source addresses be the set
>>     of unicast addresses assigned to the interface that will be used
>>     to send to the destination (the "outgoing" interface).
>>
>> Add a sysctl to enable this behaviour.
>>
>> Signed-off-by: Erik Kline <ek@google.com>
>> ---
>>  Documentation/networking/ip-sysctl.txt | 12 ++++++++++++
>>  include/linux/ipv6.h                   |  1 +
>>  include/uapi/linux/ipv6.h              |  1 +
>>  net/ipv6/addrconf.c                    | 30 +++++++++++++++++++++++++-----
>>  4 files changed, 39 insertions(+), 5 deletions(-)
>>
>> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
>> index 5fae770..d8f3e60 100644
>> --- a/Documentation/networking/ip-sysctl.txt
>> +++ b/Documentation/networking/ip-sysctl.txt
>> @@ -1435,6 +1435,18 @@ mtu - INTEGER
>>       Default Maximum Transfer Unit
>>       Default: 1280 (IPv6 required minimum)
>>
>> +restrict_srcaddr - INTEGER
>> +     Restrict candidate source addresses (vis. RFC 6724, section 4).
>> +
>> +     When set to 1, the candidate source addresses for destinations
>> +     routed via this interface are restricted to the set of addresses
>> +     configured on this interface.
>> +
>> +     Possible values are:
>> +             0 : no source address restrictions
>> +             1 : require matching outgoing interface
>> +     Default:  0
>> +
>
> I cannot get what "restrict" restricts.  How about "use_oif_addr" or
> something like that (like use_tempaddr)?
>
> --
> Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
> Technical Division, MIRACLE LINUX CORPORATION
