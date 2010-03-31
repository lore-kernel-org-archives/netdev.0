From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute u32 filter - server hang
Date: Wed, 31 Mar 2010 12:01:02 +0200
Message-ID: <4BB31D5E.5040800@trash.net>
References: <4BB3116F.803@itcare.pl> <4BB31731.9060104@trash.net> <4BB31908.5090601@itcare.pl> <4BB31A08.90809@trash.net> <4BB31D15.3000500@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58761 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933144Ab0CaKBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 06:01:04 -0400
In-Reply-To: <4BB31D15.3000500@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pawe=C5=82 Staszewski wrote:
> W dniu 2010-03-31 11:46, Patrick McHardy pisze:
>>>>> tc filter add dev eth0 protocol ip parent 1:101 u32 match ip
>>>>> protocol 1
>>>>> 0xff flowid 1:101
>>>>>
>>>>> ping 212.77.100.101
>>>>> And after this server will stop responding to anything - without =
any
>>>>> error (hang).
>>>>>
>>>>>         =20
>>>> This is caused by hfsc_classify() looping endlessly since the filt=
er
>>>> points to the originating class. hfsc_bind_tcf() is actually suppo=
sed
>>>> to prevent this, but it only prevents resolving the filter immedia=
tely
>>>> and we still run into the loop at runtime.
>>>>
>>>> This patch (based on how CBQ handles this) should abort classifica=
tion
>>>> and fall back to the default class. It would be better to simply c=
atch
>>>> this at configuration time, but that looks a bit more involved. I'=
ll
>>>> try
>>>> to look into it this weekend.
>>>>
>>>>
>>>>
>>>>       =20
>>> I check this also with htb and the same problem like with hfsc.
>>> This rules also hang my server.
>>>     =20
>> Yes, HTB doesn't even catch loops when binding filters. As I said,
>> its a larger piece of work, for now please just try the patch I
>> sent.
>>   =20
>=20
> Yes.
> Your patch fix this problem.

Thanks for testing, I'll let you know once I have a complete
patch for this problem.
