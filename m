From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH next 3/3] ipvlan: Introduce l3s mode
Date: Sat, 10 Sep 2016 11:48:52 -0700
Message-ID: <CAF2d9jjxKqPA_gk35d_9ujNFEp8U2cjoEoubHNC2sV5Dc6vG4w@mail.gmail.com>
References: <ddb5c5e8-6656-754a-8178-09096a2d333e@cumulusnetworks.com>
 <CAF2d9jj35YjaAJ4ziUSBFdgakhMY3o8M=VHU4bOfzWA=e0k_0Q@mail.gmail.com>
 <7c134452-368e-96f9-c0b1-0f6d2e507bc5@cumulusnetworks.com> <20160910.111140.1065918968661149789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: dsa@cumulusnetworks.com, mahesh@bandewar.net,
        linux-netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:34214 "EHLO
        mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751066AbcIJStR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 14:49:17 -0400
Received: by mail-yw0-f174.google.com with SMTP id g192so64879043ywh.1
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 11:49:16 -0700 (PDT)
In-Reply-To: <20160910.111140.1065918968661149789.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 10, 2016 at 11:11 AM, David Miller <davem@davemloft.net> wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Sat, 10 Sep 2016 10:25:27 -0600
>
>> On 9/9/16 4:46 PM, Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=A5=87=E0=A4=B6=
 =E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=A4=B0) wrote:
>>> On Fri, Sep 9, 2016 at 3:26 PM, David Ahern <dsa@cumulusnetworks.com> w=
rote:
>>>> On 9/9/16 3:53 PM, Mahesh Bandewar wrote:
>>>>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>>>>> index 0c5415b05ea9..95edd1737ab5 100644
>>>>> --- a/drivers/net/Kconfig
>>>>> +++ b/drivers/net/Kconfig
>>>>> @@ -149,6 +149,7 @@ config IPVLAN
>>>>>      tristate "IP-VLAN support"
>>>>>      depends on INET
>>>>>      depends on IPV6
>>>>> +    select NET_L3_MASTER_DEV
>>>>
>>>> depends on instead of select?
>>>
>>> The kbuild/kconfig-language.txt suggests that for "depends on" the
>>> option _must_ be selected otherwise menuconfig wont even present the
>>> dependent option while select positively sets the option.
>>
>> understood. VRF driver uses 'depends on'
>
> Select is for things that are largely invisible to the user.  It is more =
of
> a brute force tool that has several limitations.  For one, it doesn't
> recursively apply dependencies of the thing you selected.  This makes it
> quite trivial to create situations where you select X but it actually
> can't work because it's "depend" statements aren't satisfied.
>
I look at "select" as more of a tool than brute-force / hack. It
allows to "select" something that is largely independent and otherwise
not really harmful (of for that matter even useful). Now if you look
at L3_MASTER, it's not really useful if the users of this feature (VRF
or IPvlan) are not chosen. Hence I would say "select" fits in this
scenario better (I mean for IPvlan or VRF driver choosing select over
depend) However I agree that if you "select" some option which has
dependencies and it becomes ambiguous but that's not the case here.

> Depend is really the thing you ought to use, and yes this means that the
> user has to know to enable the thing you depend upon to make your feature
> available.  But that's just how it works.
I thought "select" is a better choice for the said reasons. I don't
mind changing it to "depend" but it would make it difficult for novice
users to figure-out why they can't see this driver-config.
