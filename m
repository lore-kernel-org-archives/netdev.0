From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the
	HTB_CAN_SEND level
Date: Wed, 4 Nov 2009 19:21:48 +0800
Message-ID: <412e6f7f0911040321o22c536fdid078f6d2225a90a0@mail.gmail.com>
References: <4AEF9862.8040404@gmail.com> <20091103080022.GA6718@ff.dom.local>
	 <412e6f7f0911030147k659e0079ibd1f424fef0a487f@mail.gmail.com>
	 <20091103100538.GC6718@ff.dom.local>
	 <412e6f7f0911030518w7a5f02a4ue8a4b6539496dd8f@mail.gmail.com>
	 <20091103230035.GA2352@ami.dom.local>
	 <412e6f7f0911031753m4af1467fn1b0326bdf17fe48b@mail.gmail.com>
	 <20091104082808.GA6224@ff.dom.local>
	 <412e6f7f0911040116q6b25b705k83e5a45464698af1@mail.gmail.com>
	 <20091104104245.GB6224@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:53498 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755224AbZKDLVo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 06:21:44 -0500
Received: by pxi9 with SMTP id 9so4555652pxi.4
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2009 03:21:49 -0800 (PST)
In-Reply-To: <20091104104245.GB6224@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 4, 2009 at 6:42 PM, Jarek Poplawski <jarkao2@gmail.com> wro=
te:
> On Wed, Nov 04, 2009 at 05:16:42PM +0800, Changli Gao wrote:
> ...
>> It is just correct. You focus on 1 second fairness, while I focus on=
 2
>> seconds fairness.
>
> The whole example was very simplified, so it all would certainly
> differ in time and real sends, especially with an interaction of
> more classes. But, generally, main HTB algorithm seems to be quite
> well tested against various fair and unfair cases, starting from
> the author's examples:
> http://luxik.cdi.cz/~devik/qos/htb/manual/userg.htm
> so, I guess, this type of a bug would really show somewhere long time
> ago.
>

This documentation is old, and after the last update 5.5.2002, there
were still bugs: http://luxik.cdi.cz/~devik/qos/htb/ .

>> The token bucket and ctoken bucket both use cl->mbuffer to control
>> rate granularities. If we don't account token bucket when the
>> corresponding class in HTB_MAY_BORROW mode, the cl->mbuffer will
>> become useless.
>
> cl->mbuffer is only to limit some extreme effects, so more of an
> exception, not a main tool of rate control. (It really should be
> useless most of the time if classes don't stop sending and aren't
> deprived of their full rate for really long time.)
>

I don't think so. Although a class's tokens may be negative, but its
ctokens may be positive. Charging its tokens is to prevent its cmode
from being changed to HTB_CAN_SEND from HTB_CANT_SEND directly.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
