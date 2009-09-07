From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Network hangs with 2.6.30.5
Date: Mon, 7 Sep 2009 07:21:43 +0000
Message-ID: <20090907072143.GA5966@ff.dom.local>
References: <pan.2009.09.03.19.55.37.672875@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Holger Hoffstaette <holger.hoffstaette@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:61690 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbZIGHVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 03:21:52 -0400
Received: by bwz19 with SMTP id 19so1389743bwz.37
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2009 00:21:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <pan.2009.09.03.19.55.37.672875@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03-09-2009 21:55, Holger Hoffstaette wrote:
> On Thu, 03 Sep 2009 21:27:08 +0200, Eric Dumazet wrote:
>=20
>> Holger Hoffstaette a =E9crit :
>>> Problem found! At least for me..
>>>
>>>> On 01-09-2009 17:32, Holger Hoffstaette wrote:
>>>>> On Tue, 01 Sep 2009 16:17:08 +0200, Holger Hoffstaette wrote:
>>>>>
>>>>> [network regressions in .30]
>>> I got the git .30.y stable tree and reverted various e1000 commits =
that
>>> seemed to coincide with the various .30-rc releases but nothing hel=
ped.
>>> Also no relation to offloads etc.
>>>
>>> However I did notice that the "stuck squid" problem seemed to magic=
ally
>>> fix itself after a few seconds - then hang again, fix itself after
>>> timeouts etc. So I suspected something TCP related and BINGO!
>>>
>>> Turns out I had both tcp_tw_recycle and tcp_tw_reuse set to 1 for
>>> reasons I don't want to explain. :)
>>>
>>> I can now arbitrarily fix the hanging behaviour by setting
>>> tcp_tw_recycle to 0, and cause hangs by setting it to 1 again. For
>>> obvious reasons this seems to affect squid more than other tasks wi=
th
>>> more long-lived connections. What is the right behaviour? beats me.
>>>
>>> tcp_tw_reuse does not appear to play a role, so the real culprit at
>>> least in my case seems to be tcp_tw_recycle. In previous releases t=
his
>>> (and tw_reuse) was necessary for various server tasks.
>>>
>>> Nevertheless, something has changed between .29 and .30 that "broke=
" the
>>> previous behaviour. Whether this is progress or an regression I can=
not
>>> say. Maybe someone else has an idea?
>>>
>>>
>> Well... not yet :)
>>
>> We probably can reproduce this problem with any NIC...
>>
>> Could you send from the 'buggy' setup
>>
>> $ grep . /proc/sys/net/ipv4/*
>=20
> Sure:
=2E..
> Was that somewhat helpful? I can certainly create a full trace but th=
at's
> going to be big.

Congratulations for finding the culprit!

While Eric is analyzing your data, I guess you could try reverting
some stuff around this tcp_tw_recycle, and my tcp ignorance would
point these commits for the beginning:

http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.30.y.git;a=
=3Dcommitdiff;h=3Dfc1ad92dfc4e363a055053746552cdb445ba5c57
http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.30.y.git;a=
=3Dcommitdiff;h=3Dc887e6d2d9aee56ee7c9f2af4cec3a5efdcc4c72

Regards,
Jarek P.

PS: you don't have to remove anybody from the Cc line on this list.;-)
