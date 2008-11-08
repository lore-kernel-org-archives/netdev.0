From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: fix /proc/net/snmp as memory corruptor
Date: Sat, 8 Nov 2008 09:42:26 +0300
Message-ID: <20081108064226.GA32078@x200.localdomain>
References: <20081108002208.GB17721@alice> <20081108010237.GA7062@x200.localdomain> <20081108025256.GA16001@x200.localdomain> <20081108033618.GA27960@x200.localdomain> <4915295B.4050102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Sesterhenn <snakebyte@gmx.de>, davem@davemloft.net,
	netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.178]:8756 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbYKHGjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 01:39:06 -0500
Received: by ik-out-1112.google.com with SMTP id c29so1348542ika.5
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 22:39:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4915295B.4050102@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 08, 2008 at 06:53:31AM +0100, Eric Dumazet wrote:
> Alexey Dobriyan a =E9crit :
>> On Sat, Nov 08, 2008 at 05:52:56AM +0300, Alexey Dobriyan wrote:
>>> On Sat, Nov 08, 2008 at 04:02:37AM +0300, Alexey Dobriyan wrote:
>>>> On Sat, Nov 08, 2008 at 01:22:08AM +0100, Eric Sesterhenn wrote:
>>>>> running a bunch of network related stresstests (isic, isicng,=20
>>>>> ...) and trying to read all files in /proc afterwards gave me two
>>>>> oopses. I was able to reproduce them on another box with
>>>>> a different config. I was able to reproduce this on 2.6.24 too,
>>>>> so this is no regression. The icmpsic is version 0.06. The=20
>>>>> minimal testcase to trigger this:
>>>>>
>>>>> ------------8<----------------
>>>>> #!/bin/bash
>>>>>
>>>>> icmpsic -s 127.0.0.1 -d 127.0.0.1 -p 100000
>>>>>
>>>>> find /proc/net/ | xargs cat > /dev/null
>>>>>
>>>>> cat /proc/net/ip_mr_cache
>>>>> cat /proc/net/ip_mr_vif
>>>>> ------------8<----------------
>>>>>
>>>>>
>>>>> root@computer-desktop:~/testing# cat /proc/338/net/ip_mr_cache
>>>>>
>>>>> [ 1572.702100] BUG: unable to handle kernel NULL pointer derefere=
nceat 000001c1
>>>>> [ 1572.702588] IP: [<c05942c6>] ipmr_mfc_seq_show+0x26/0xf0
>>>> Reproduced.
>>> 	icmpsic -s 127.0.0.1 -d 127.0.0.1 -p 100000
>>> 	cat /proc/net/snmp				# sic
>>> 	cat /proc/net/ip_mr_cache
>>>
>>> mfc_cache_array is full of small integers
>>>
>>> 	[0] =3D 0x1a8
>>> 	[1] =3D 0x1a9
>>>
>>> and so on.
>>
>> OK, this minimally fixes mfc_cache_array corruption.
>>
>> Someone was scared of 16 integers on stack. :^)
>
> Good spot Alexey :)

This patch works too.
