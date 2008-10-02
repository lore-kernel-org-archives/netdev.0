From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd)
Date: Thu, 2 Oct 2008 14:08:14 +0200 (CEST)
Message-ID: <alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi> <48e3a4e5.0d1d640a.4cd3.06e9@mx.google.com> <alpine.LFD.1.10.0810012140360.5549@apollo.tec.linutronix.de> <48e3e835.0906c00a.2cd1.2fd1@mx.google.com> <alpine.LFD.1.10.0810021142370.5549@apollo.tec.linutronix.de>
 <48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-923850844-1222949296=:5549"
Cc: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?D=E2niel_Fraga?= <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:54712 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409AbYJBMI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 08:08:28 -0400
In-Reply-To: <48e4adb8.0807c00a.62b8.ffff87d6@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-923850844-1222949296=:5549
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Thu, 2 Oct 2008, Dâniel Fraga wrote:

> On Thu, 2 Oct 2008 12:42:44 +0200 (CEST)
> Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> >   echo sym-verbose > /debug/tracing/iter_ctrl
> 
> 	Ok, this one I changed to:
> 
> echo verbose > /debug/tracing/iter_ctrl
> 
> 	;) since there's no sym-verbose.
> 
> > Find below a patch which disables the tracer when the listen overflow
> > is detected. It could occassionally be hit in a legimate case as well,
> > but we did not come up with any better idea.
> 
> 	Ok, I applied the patch, but it returns this error:
> 
>   CC      kernel/trace/ftrace.o
> kernel/trace/ftrace.c: In function 'stop_event_tracer_now':
> kernel/trace/ftrace.c:73: error: 'tracer_enabled' undeclared (first use in this function)
> kernel/trace/ftrace.c:73: error: (Each undeclared identifier is reported only once
> kernel/trace/ftrace.c:73: error: for each function it appears in.)
> make[2]: *** [kernel/trace/ftrace.o] Error 1
> make[1]: *** [kernel/trace] Error 2
> make: *** [kernel] Error 2

grmbl. tracer_enabled should have been ftrace_enabled of course.

Thanks,

	tglx
--8323328-923850844-1222949296=:5549--
