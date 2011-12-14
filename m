From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: IFB and bridges
Date: Wed, 14 Dec 2011 20:36:34 +0100
Message-ID: <4EE8FAC2.4090303@itcare.pl>
References: <9ab07532-3d46-4e4a-8baf-5863b0cec5db@jasiiieee>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:42075 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755103Ab1LNTgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 14:36:48 -0500
In-Reply-To: <9ab07532-3d46-4e4a-8baf-5863b0cec5db@jasiiieee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2011-12-12 01:42, John A. Sullivan III pisze:
>
> ----- Original Message -----
>> From: "Eric Dumazet"<eric.dumazet@gmail.com>
>> To: "John A. Sullivan III"<jsullivan@opensourcedevel.com>
>> Cc: netdev@vger.kernel.org
>> Sent: Sunday, December 11, 2011 5:00:59 PM
>> Subject: Re: IFB and bridges
>>
>> Le dimanche 11 d=C3=A9cembre 2011 =C3=A0 17:38 -0500, John A. Sulliv=
an III a>
>>> I know IFB is often used for ingress but I wasn't really thinking
>>> of
>>> ingress filtering.  Let's say I have a 12 port Linux switch.  If
>>> any
>>> of the ports become backlogged, I want them to prioritize time
>>> sensitive traffic so I implement traffic shaping but I don't want
>>> to
>>> have to define my qdiscs, classes, and filters 12 times over if
>>> they
>>> are all the same.  So I would direct each port to an IFB (not sure
>>> if
>>> that's intolerable overhead), have a single set of qdiscs, classes,
>>> and filters, and, once those are applied, the packet arrives back
>>> on
>>> the same interface and proceeds assuming if has not been dropped or
>>> delayed. - John
>> Really ? How are you going to shape a single IFB device, if you
>> really
>> have independant 12 ports. (Its a switch, not a hub after all)
>>
>> A script can define your qdiscs/classes/filters hundred times, or on=
e
>> thousand times, and writing such a script is far more easier than
>> setup
>> IFB.
>>
>>
>>
>>
> <grin>  That's why I thought I'd ask the experts :) - John
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
Also directing all traffic from all 12 ports is not good idea :)
It is performance killer

IFB can't handle too much pps

Also - You can't have too many tc filters/classes on one single IFB=20
device because this is also performance killer.
