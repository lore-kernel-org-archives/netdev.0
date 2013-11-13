From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: how to mix bridges and bonding inc. vlans correctly on Kernel
 > 3.10
Date: Wed, 13 Nov 2013 10:05:36 -0500
Message-ID: <52839540.6020908@gmail.com>
References: <52838590.5070806@profihost.ag> <20131113141244.GM19702@redhat.com> <52838AC8.8070005@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:63869 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755066Ab3KMPFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 10:05:39 -0500
Received: by mail-vc0-f176.google.com with SMTP id ld13so360637vcb.7
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 07:05:39 -0800 (PST)
In-Reply-To: <52838AC8.8070005@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2013 09:20 AM, Stefan Priebe - Profihost AG wrote:
> Hi Falico,
> Am 13.11.2013 15:12, schrieb Veaceslav Falico:
>> On Wed, Nov 13, 2013 at 02:58:40PM +0100, Stefan Priebe - Profihost AG
>> wrote:
>>> Hello,
>>>
>>> while my vlans, bridging and bonding stuff was working until 3.9 i never
>>> thought about how it is right. So maybe i was always wrong.
>>>
>>> I've this:
>>>
>>> eth2
>>>      \
>>>       -- bond1 -- vmbr1
>>>      /
>>> eth3
>>>
>>> This works fine and as expected now i want to have a vlan using the
>>> bonding and using a bridge.
>>>
>>> I the past i had this:
>>> eth2
>>>      \
>>>       -- bond1 -- vmbr1
>>>      /              \
>>> eth3                 \ vmbr1.3000
>>>                            \ ---- tap114i1
>>>
>>> This was working fine until 3.9.X since 3.10. Right now using 3.10 i
>>> need to put eth2 and eth3 into promisc mode to get it working ;-( this
>>> is bad!
>>
>> As a guess - do you use arp monitoring for bonding? Try using miimon -
>> there were some issues with it in 3.10, which were fixed by some huge
>> patchsets that will never hit 3.10 stable.
>> Also, the bonding configuration would be welcome.
>
> Debian Bonding konfiguration looks like this:
> auto bond1
> iface bond1 inet manual
>          slaves eth2 eth3
>          bond-mode 802.3ad
>          bond_miimon 100
>          bond_updelay 200
>          bond_downdelay 0
>
> This should be miimon using lacp and not arp isn't it?
> Anything more needed?
>

Hmm..  With 802.3ad mode, when the bond is a port on the bridge, the 
bond should place all of its ports into promiscuous mode.  Do you see 
the the kernel messages that say that?

-vlad

> One thing i forgot the one with vmbr1.3000 does not work at all eben not
> with promisc mode. The one below works fine if i set eth2 and eth3 into
> promisc mode.
>
> Stefan
>
>>> I also tried this one without success:
>>> eth2
>>>      \
>>>       -- bond1 -- vmbr1
>>>      /     \
>>> eth3        ----- bond1.3000 --- vmbr1v3000
>>>                                      \ ---- tap114i1
>>>
>>>
>>>
>>> Greets,
>>> Stefan
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
