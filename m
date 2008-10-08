From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Wed, 8 Oct 2008 23:44:39 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810082329250.7599@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
 <48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com>
 <alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de>
 <48e3e835.0906c00a.2cd1.2fd1@mx.google.com>
 <alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
 <48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
 <alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
 <48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
 <alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
 <Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
 <48e5364d.0603c00a.6e25.fffff993@mx.google.com>
 <Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
 <48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com> <alpine.LFD.2.00.0810052008131.3398@apollo>
 <48ed0b51.0913c00a.7715.4aa7@mx.google.com> <alpine.LFD.2.00.0810082154420.3237@apollo>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="8323328-1611213262-1223495761=:3237"
Cc: "=?ISO-8859-1?Q?D=E2niel_Fraga?=" <fragabr@gmail.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45983 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbYJHUom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 16:44:42 -0400
In-Reply-To: <alpine.LFD.2.00.0810082154420.3237@apollo>
Content-ID: <Pine.LNX.4.64.0810082329251.7599@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1611213262-1223495761=:3237
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810082329252.7599@wrl-59.cs.helsinki.fi>

On Wed, 8 Oct 2008, Thomas Gleixner wrote:

> On Wed, 8 Oct 2008, Dâniel Fraga wrote:
> 
> > On Sun, 5 Oct 2008 20:09:22 +0200 (CEST)
> > Thomas Gleixner <tglx@linutronix.de> wrote:
> > 
> > > The cat /debug/tracing/tracing_enabled == 1 might be just a user space
> > > interface thingy.
> > > 
> > > Thanks,
> > 
> > 	Thomas, Ilpo etc, I got a trace exactly after the patch
> > provided by Thomas detected the stall:
> > 
> > http://www.abusar.org/ftrace/trace-final.txt.bz2
> > 
> > 	Thomas, since you didn't reply to the previous messages, I
> > assume the previous traces were invalid. But could you please check
> > this one?
>
> Will do. Sorry was distracted. Steven Rostedt posted a patch to stop
> the tracer really from the kernel, I need to verify that it works on
> .27. Will do tomorrow when my brain is more awake than now.

I hope we're not chasing a partial ghost btw since there seem to be,
after all, two "independent" failures which look similar, one at the 
server and the other at the client. So the strace we were looking earlier 
_might_ actually be from a case where the client was stalling instead of 
the server (we don't have /proc/net/tcp of that case so I cannot 
decide for sure though I might as well be wrong and it was a valid 
server case straced)... Anyway, this ftrace may still reveal something as 
it's clearly triggering due to server side listenoverflow which is known 
to happen during the server side event but the thing we want to find might 
be something else than what strace was giving.

Is there some compatible kd tool for ftrace that got included? I only 
found one from a kft patch but I suppose the format is different or 
something as I got no output from it, or I'm just stupid and don't 
understand how I'm supposed to use it with the logs Daniel gathered :-).

I'll try to take a look as well tomorrow or Friday but I'm pretty busy
already and will be travelling starting from Sunday to Wednesday so my 
responses might get a bit delayed.


-- 
 i.
--8323328-1611213262-1223495761=:3237--
