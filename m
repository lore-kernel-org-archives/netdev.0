From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Thu, 19 Nov 2009 22:41:11 -0800
Message-ID: <65634d660911192241q30a3928bg44854fc929dae218@mail.gmail.com>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
	 <87hbt0kaae.fsf@basil.nowhere.org>
	 <65634d660911160902t677a4fb4r71602cb0d10f1cce@mail.gmail.com>
	 <20091119100805.GA22938@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:59433 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552AbZKTGlK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 01:41:10 -0500
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id nAK6fEQJ013652
	for <netdev@vger.kernel.org>; Fri, 20 Nov 2009 06:41:15 GMT
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by wpaz37.hot.corp.google.com with ESMTP id nAK6eq29020044
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 22:41:12 -0800
Received: by pwj1 with SMTP id 1so1931414pwj.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 22:41:12 -0800 (PST)
In-Reply-To: <20091119100805.GA22938@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> What are the standard deadlocks? =A0Looks like __send_remote_softirq
>> will call __smp_call_function with irq's disabled...
>
> The traditional deadlock (that was before the queue smp_call_function=
)
> was
>
> A =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0B
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grab lock
> interrupts off
> spin on lock
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 send IPI
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait for specific CPU
>
> never answers because
> interrupts are off
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hangs forever
>
>
> I think with the queued smp_call_function it's better because
> the locks are only hold much shorter and that particular scenario
> is gone, but I'm not sure the problem has fully gone away.
>
> At least there are still plenty of WARN_ON( ... irqs_disabled()) in
> kernel/smp.c
>

So is send_remote_softirq also broken according to this?
