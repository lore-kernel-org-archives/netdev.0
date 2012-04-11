From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: via-rhine: Problem with lost link after a while
Date: Thu, 12 Apr 2012 00:21:24 +0200
Message-ID: <20120411222124.GA20605@electric-eye.fr.zoreil.com>
References: <CACPM=kWa=UWuCMaYAtVMGJ7pzCy-PfyNRWBSuJnTZGtssU0W6g@mail.gmail.com> <20120410204249.GA26627@electric-eye.fr.zoreil.com> <CACPM=kWsU8QZOHqwEThTQCuSSvaTDoxO1d17EyoW=+kx8QG3vw@mail.gmail.com> <20120410225534.GA28480@electric-eye.fr.zoreil.com> <4F8553BF.6030303@secomea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andreas Mohr <andi@lisas.de>
To: Svenning =?utf-8?B?U8O4cmVuc2Vu?= <sss@secomea.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54050 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933500Ab2DKWZd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 18:25:33 -0400
Content-Disposition: inline
In-Reply-To: <4F8553BF.6030303@secomea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Svenning S=C3=B8rensen <sss@secomea.com> :
[...]
> Regarding the "Tx descriptor busy" test: no, I didn't see it
> trigger, I just put it there just in case because I suspected there
> could be a race due to the lock-free tx path.
> But I'm glad if you're confident that it can't happen :)

Almost :o)

Without the patch it may happen in mainline. Once the napi Tx completio=
n
function checks if queueing is stopped before enabling it, it should no=
t
happen though. The patch should fix the race where queuing is not enabl=
ed
as well.

That being said, I would welcome a pony^W^W some testing on a multi-cor=
e
system with lots of Tx and enough irq from a different (non via-rhine)
source to starve the softirq processing.

--=20
Ueimor
