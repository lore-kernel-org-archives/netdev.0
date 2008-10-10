From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: deadlocks if use htb
Date: Fri, 10 Oct 2008 16:54:59 +0400
Message-ID: <48EF50A3.7090607@bigtelecom.ru>
References: <20081010075640.GA5204@ff.dom.local> <48EF4B72.8080305@trash.net> <48EF4BEE.7030400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	Denys <denys@visp.net.lb>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:44290 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755105AbYJJMzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 08:55:03 -0400
In-Reply-To: <48EF4BEE.7030400@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Patrick McHardy wrote:
>> Jarek Poplawski wrote:
>>> On 10-10-2008 07:44, Badalian Vyacheslav wrote:
>>>> Hello all!
>>>
>>> Hello Slavon,
>>>
>>>> Please look to if you have time:
>>>> http://bugzilla.kernel.org/show_bug.cgi?id=3D11718
>>>>
>>>> We have deadlocks at few PC one times in week.
>>>> I can test any patches to detect and fix problem.
>>>> Now i test 2.6.27-rc kernel at one PC.
>>>
>>> A similar bug was reported by Denys Fedoryshchenko but it wasn't fu=
lly
>>> diagnosed. Anyway it looks like hardware dependent. The patch below
>>> can sometimes help. 2.6.27 may have this fixed too (some other way)=
=2E
>>
>> I doubt its hardware related, whats happening is that the hrtimer
>> insertion gets into an endless loop because the rb tree (or node)
>> apparently has a loop. I went through the qdiscs' use of hrtimers
>> again, but can't spot any error there.
>>
>> Denys, did your systems also have CONFIG_HIGH_RES_TIMERS=3Dn?
>
> Badalian, please try enabling CONFIG_DEBUG_OBJECTS and post the
> results, if any.

i have some results with CONFIG_HIGH_RES_TIMERS=3Dn and
CONFIG_HIGH_RES_TIMERS=3Dy
Ok... i recompile kernel... simple wait crash for reboot =3D)
Now i have pc:

1. 2.6.27 with patch
2. 2.6.26.6 with htb_hysteresis=3D1 and CONFIG_DEBUG_OBJECTS=3Dn
3. 2.6.26.6 with htb_hysteresis=3D1 and CONFIG_DEBUG_OBJECTS=3Dy (wait =
for
crash for reboot)
4. 2 servers deadlocked and not rebooted after panic (2.6.26.5
kernel)... need for drive to its for reboot...
5. 4 pc with 2.6.24-rc7-git2 that also do equal shaping but not have
crashes(its on other hardware)

> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

