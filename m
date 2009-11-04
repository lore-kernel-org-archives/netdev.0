From: Martin Devera <martin.devera@cdi.cz>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the	HTB_CAN_SEND
 level
Date: Wed, 04 Nov 2009 11:58:59 +0100
Message-ID: <4AF15E73.30806@cdi.cz>
References: <4AEF9862.8040404@gmail.com> <20091103080022.GA6718@ff.dom.local> <412e6f7f0911030147k659e0079ibd1f424fef0a487f@mail.gmail.com> <20091103100538.GC6718@ff.dom.local> <412e6f7f0911030518w7a5f02a4ue8a4b6539496dd8f@mail.gmail.com> <20091103230035.GA2352@ami.dom.local> <412e6f7f0911031753m4af1467fn1b0326bdf17fe48b@mail.gmail.com> <20091104082808.GA6224@ff.dom.local> <412e6f7f0911040116q6b25b705k83e5a45464698af1@mail.gmail.com> <20091104104245.GB6224@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.cdi.cz ([80.95.109.117]:52015 "EHLO luxik.cdi.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754747AbZKDLHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 06:07:51 -0500
In-Reply-To: <20091104104245.GB6224@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Nov 04, 2009 at 05:16:42PM +0800, Changli Gao wrote:
> ...
>> It is just correct. You focus on 1 second fairness, while I focus on 2
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
>> The token bucket and ctoken bucket both use cl->mbuffer to control
>> rate granularities. If we don't account token bucket when the
>> corresponding class in HTB_MAY_BORROW mode, the cl->mbuffer will
>> become useless.
> 
> cl->mbuffer is only to limit some extreme effects, so more of an
> exception, not a main tool of rate control. (It really should be
> useless most of the time if classes don't stop sending and aren't
> deprived of their full rate for really long time.)

Hello,

yes you are right. If I remember correctly, I tried to charge "rate"
tokens up to root in early versions (which makes some sense) but problem
is with many interior classes stuck at extreme mbuffer value, losing
responsivity. Also it didn't played well with prio settings (class
stalls).
Bacause we don't charge "rate" now, some amount of burst can accumulate
in each interior class and decrease fairness at the same prio level a 
bit. However from measurments I did, these bursts of unfairness are
hidded by regular "bursting" of rate and ceil token buckets.

devik
