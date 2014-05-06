From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: RFC: A reduced Linux network stack for small systems
Date: Tue, 6 May 2014 14:05:30 -0700
Message-ID: <CAADnVQLR1ayAjmaRMq4+56BUTEXafgpPGfenvVrq8pGSq3+nVg@mail.gmail.com>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<CAFLxGvww8t-PpuS3B=dFvn8k3xBydk3CgA=qoLyEbkKJZJ0xhQ@mail.gmail.com>
	<1399383246.8767.99.camel@empanada>
	<CAADnVQLYiNfXRrXc=VZkGEFDbNhF63AzPg6Gyu6P1SF=6AiO7g@mail.gmail.com>
	<1399390490.8767.122.camel@empanada>
	<CAADnVQ+nCtshedoDWN+QgiKzsCzBcojZOzrhkfzsqyXTpi4L=w@mail.gmail.com>
	<20140506200047.GB5619@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Zanussi <tom.zanussi@linux.intel.com>,
	Richard Weinberger <richard.weinberger@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:56573 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755794AbaEFVFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 17:05:31 -0400
In-Reply-To: <20140506200047.GB5619@two.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 6, 2014 at 1:00 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> not quite. I'm saying: no extra optimizations, no GCC changes.
>> Compile kernel as-is. Most functions have a stub for mcount() already.
>> Use it to track whether kernel function was called or not.
>> Collect this data in userspace (as perf already does), add few
>> more functions that had 'notrace' attribute on them, and feed this into
>> special linker that unpacks existing vmlinux, throws away cold functions,
>> relocates the rest and here you have tiny vmlinux without recompilation.
>
> That's very difficult for networking code. How would you know you
> exercised all the corner cases in the TCP stack? And you wouldn't
> want a remotely exploitable system because some important error
> handler is missing.

I think removing functions by linker will get you the same level of bugs
then stubbing functions out by kconfig.
One doesn't have to use profile feedback to remove them.
Either linker or config approach seems pretty much equivalent to me.
In case of config, a lot of patches need to be reviewed and maintained.
In case of linker the embedded setup can pick and choose without burdening
mainline. If it crashes, it will be clear that it crashed due to call to removed
function. Iteratively you'll get a setup that works for this
particular application.
Both approaches are full of potential crashes, undoing removal is much
easier with linker. Best solution is to add memory and don't mess with .text.

> I agree it may work for some other subsystems.
>
> -Andi
