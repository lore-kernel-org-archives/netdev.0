From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: iproute u32 filter - server hang
Date: Wed, 31 Mar 2010 11:59:49 +0200
Message-ID: <4BB31D15.3000500@itcare.pl>
References: <4BB3116F.803@itcare.pl> <4BB31731.9060104@trash.net> <4BB31908.5090601@itcare.pl> <4BB31A08.90809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:54611 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933077Ab0CaJ74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 05:59:56 -0400
In-Reply-To: <4BB31A08.90809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-03-31 11:46, Patrick McHardy pisze:
> Pawe=C5=82 Staszewski wrote:
>   =20
>> W dniu 2010-03-31 11:34, Patrick McHardy pisze:
>>     =20
>>> Pawe=C5=82 Staszewski wrote:
>>>
>>>       =20
>>>> I find some problem with iproute2 and u32 filters
>>>>
>>>> To reproduce the problem (need to make one mistake in filter paren=
t
>>>> declaration 1:101):
>>>>
>>>> ...
>>>> tc filter add dev eth0 protocol ip parent 1:101 u32 match ip proto=
col 1
>>>> 0xff flowid 1:101
>>>>
>>>> ping 212.77.100.101
>>>> And after this server will stop responding to anything - without a=
ny
>>>> error (hang).
>>>>
>>>>         =20
>>> This is caused by hfsc_classify() looping endlessly since the filte=
r
>>> points to the originating class. hfsc_bind_tcf() is actually suppos=
ed
>>> to prevent this, but it only prevents resolving the filter immediat=
ely
>>> and we still run into the loop at runtime.
>>>
>>> This patch (based on how CBQ handles this) should abort classificat=
ion
>>> and fall back to the default class. It would be better to simply ca=
tch
>>> this at configuration time, but that looks a bit more involved. I'l=
l try
>>> to look into it this weekend.
>>>
>>>
>>>
>>>       =20
>> I check this also with htb and the same problem like with hfsc.
>> This rules also hang my server.
>>     =20
> Yes, HTB doesn't even catch loops when binding filters. As I said,
> its a larger piece of work, for now please just try the patch I
> sent.
>   =20

Yes.
Your patch fix this problem.


Thanks
Pawe=C5=82


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   =20
