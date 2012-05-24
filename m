From: =?UTF-8?B?QWxleCBWaWxsYWPDrcKtcyBMYXNzbw==?=
	<a_villacis@palosanto.com>
Subject: Re: Fwd: Re: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x277/0x280()
Date: Thu, 24 May 2012 10:26:54 -0500
Message-ID: <4FBE533E.6030107@palosanto.com>
References: <20120503064726.GA17337@electric-eye.fr.zoreil.com> <4FA2A6A4.1030308@ceibo.fiec.espol.edu.ec> <4FA3EE49.7070805@palosanto.com> <4FA59F5B.5000800@palosanto.com> <20120505230155.GA3300@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.palosanto.com ([201.234.196.171]:46092 "EHLO
	pbx.palosanto.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064Ab2EXPuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 11:50:04 -0400
In-Reply-To: <20120505230155.GA3300@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 05/05/12 18:01, Francois Romieu escribi=C3=B3:
> Alex Villac=C3=ADs Lasso<a_villacis@palosanto.com>  :
> [...]
>> It happened again, on a non-tainted kernel. The dmesg log is attache=
d.
> It sucks.
>
> Can you do a poor man's bisection of the r8169 driver between v3.3 an=
d
> v3.4-rc1  (aka 'git cat-file -p $some_rev:drivers/net/ethernet/realte=
k/r8169.c')
>
> I'd try 1e874e041fc7c222cbd85b20c4406070be1f687a then
> 8027aa245bbd125350f6a78c5a78771d143aba55 if it does not fail.
>
I tried a bisection around the drivers/net/ethernet/realtek directory. =
I am confident about the bad selections, but not so much about the good=
 selections, even though I waited a full day with the bittorrent client=
 on the background before marking a commit=20
as good.

According to my bisection, the first bad commit is 036dafa28da1e2565a85=
29de2ae663c37b7a0060 . Here is my bisection log:

git bisect start '--' 'drivers/net/ethernet/realtek'
# bad: [dd775ae2549217d3ae09363e3edb305d0fa19928] Linux 3.4-rc1
git bisect bad dd775ae2549217d3ae09363e3edb305d0fa19928
# good: [c16fa4f2ad19908a47c63d8fa436a1178438c7e7] Linux 3.3
git bisect good c16fa4f2ad19908a47c63d8fa436a1178438c7e7
# good: [eeb69aa443e8cdc945405c48f21ce03f5a3b1f86] 8139too: Support RX-=
=46CS flag.
git bisect good eeb69aa443e8cdc945405c48f21ce03f5a3b1f86
# bad: [e27566ed370da09e3b812d3d76dce002915a5bdd] r8169: move the drive=
r removal method to the end of the driver file.
git bisect bad e27566ed370da09e3b812d3d76dce002915a5bdd
# bad: [036dafa28da1e2565a8529de2ae663c37b7a0060] r8169: add byte queue=
 limit support.
git bisect bad 036dafa28da1e2565a8529de2ae663c37b7a0060
# good: [79d0c1d26e1eac0dc5b201e66b65cc5e4e706743] r8169: Support RX-FC=
S flag.
git bisect good 79d0c1d26e1eac0dc5b201e66b65cc5e4e706743
# good: [8027aa245bbd125350f6a78c5a78771d143aba55] r8169: add 64bit sta=
tistics.
git bisect good 8027aa245bbd125350f6a78c5a78771d143aba55
