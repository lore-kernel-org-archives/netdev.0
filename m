From: Yury Polyanskiy <ypolyans@princeton.edu>
Subject: Re: [PATCH] xfrm: SAD entries do not expire after suspend-resume
Date: Mon, 11 May 2009 16:07:25 -0400
Message-ID: <ea182b20905111307w2cdbe18dw9f9fde474216c219@mail.gmail.com>
References: <20090511142101.639cb5d6@penta.localdomain>
	 <1242066617.6656.1311.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	yoshfuji@linux-ipv6.org, mingo@elte.hu,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:27859 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755299AbZEKUHZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 16:07:25 -0400
Received: by yx-out-2324.google.com with SMTP id 3so1787435yxj.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2009 13:07:25 -0700 (PDT)
In-Reply-To: <1242066617.6656.1311.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 11, 2009 at 2:30 PM, Peter Zijlstra <peterz@infradead.org> =
wrote:
> On Mon, 2009-05-11 at 14:21 -0400, Yury Polyanskiy wrote:

>> (2) it can not be ported to anything post 2.6.28-rc7 because hrtimer=
's
>> callbacks are run in hardirq context ever since. This would require =
a
>> major rewrite of xfrm_state's locking (i.e. replacing spin_lock_bh()
>> with spin_lock_irqsave() at least) which is (a) outside of my compet=
ence
>> and (b) will introduce excessive irq-disabled codepaths.
>>
>> =A0 Due to (2) I am copying the authors of the hrtimer's patch. Unle=
ss
>> there is an alternative (to hrtimer_start) way of requesting a
>> CLOCK_REALTIME softirq callback the only solution I could think of i=
s
>> to hook into PM_POST_HIBERNATION+PM_POST_SUSPEND and force all of th=
e
>> timers on xfrm_state_all list to go off after resume.
>
> Given that the whole problem is suspend related, this last option sou=
nds
> like the best thing.
>

Can somebody from the Networking Team please confirm that the other
sources of time leaps can indeed be neglected? (such as ntp
corrections e.g.)

Best,
YP
