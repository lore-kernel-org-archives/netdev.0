From: Mike Sinkovsky <msink@permonline.ru>
Subject: Re: [PATCH v6 1/2] Ethernet driver for the WIZnet W5300 chip
Date: Wed, 04 Apr 2012 17:00:19 +0600
Message-ID: <4F7C29C3.9000306@permonline.ru>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru> <1333450726-24455-2-git-send-email-msink@permonline.ru> <20120403133619.GA3960@sirena.org.uk> <4F7BE7A4.1060202@permonline.ru> <20120404100148.GB3002@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.ccl.ru ([195.222.140.73]:60471 "EHLO mail4.ccl.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756133Ab2DDLA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 07:00:27 -0400
In-Reply-To: <20120404100148.GB3002@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

04.04.2012 16:01, Mark Brown =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=
:
> On Wed, Apr 04, 2012 at 12:18:12PM +0600, Mike Sinkovsky wrote:
>> 03.04.2012 19:36, Mark Brown =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=
=BB:
>
>>> ...you use devm_request_threaded_irq() here and rely on it for clea=
nup.
>>> Are you sure there's no possibility of the interrupt firing after y=
ou
>>> start to tear down the device?
>
>>> By using a specifically threaded IRQ you're also adding a performan=
ce
>>> overhead for no good reason if you can call netdev_carrier_*() from=
 IRQ
>>> context and the GPIO is capable of generating a hard IRQ.  If you u=
se
>>> request_any_context_irq() instead then the driver will get a hard I=
RQ if
>>> that's supported.
>
>> There isn't devm* variant of request_any_context_irq(), and using
>> plain version looks inconsistent with other resources handling.
>> Anyway, this is not performance critical procedure, and latency
>> around 100 millisecond is acceptable. Some our boards even don't
>> have this gpio at all, and nothing bad happens, just userspace
>> doesn't know is carrier on or off.
>
> None of this addresses the primary concern which is that because you'=
re
> not (as far as I can tell) ensuring that the interrupt won't fire the
> driver might crash if the interrupt fires in between the resources it
> needs to handle the interrupt being deallocated and the interrupt bei=
ng
> unregistered.  Managed interrupts are relatively tricky to use becaus=
e
> of this issue, with most things like memory it doesn't matter exactly
> when it's deallocated but interrupts can potentially trigger actions
> themselves.
>
> If you can use it and devm_request_any_context_irq() doesn't exist it=
'd
> be better to add it.

Ok, now I understand - better don't use devm* functions for interrupts,=
=20
use plain request* in probe() and free_irq() in remove().

Will post v8.


--=20
Mike
