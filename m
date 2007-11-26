From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: Re: [PATCH 4/4] atm/ambassador: kmalloc + memset conversion to
 kzalloc
Date: Mon, 26 Nov 2007 05:29:35 -0500 (EST)
Message-ID: <alpine.LFD.0.9999.0711260523420.12603@localhost.localdomain>
References: <007f01c8300b$1b89ac40$9c94fea9@jason>  <alpine.LFD.0.9999.0711260409110.551@localhost.localdomain> <b25c3fa70711260223w5a15bb1bk4652b3ab8f05c40c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil,
	linux-kernel@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:47329 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535AbXKZKbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 05:31:33 -0500
In-Reply-To: <b25c3fa70711260223w5a15bb1bk4652b3ab8f05c40c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Nov 2007, Joonwoo Park wrote:

> 2007/11/26, Robert P. J. Day <rpjday@crashcourse.ca>:
> > i'm not sure the above is a safe thing to do, as you're zeroing that
> > area, then making a function call and assuming, upon entry to the
> > function call, that the caller has done the right thing.  i don't see
> > how you can count on that, depending on who else might want to call
> > that routine and whether they get sloppy about it.  unless you're
> > prepared to guarantee that there will never be another call to
> > setup_dev() from elsewhere.
>
> Thanks for your response. But setup_dev is static function and only
> amb_init calls it.

i realized that.  but all you can say is that only amb_init() calls
setup_dev() *currently*.  when you're not looking, someone else might
(for whatever reason) call setup_dev() from elsewhere, and *that* call
might not zero that memory area.

IMHO, the only safe transforms of kmalloc+memset -> kzalloc are those
in which the flow of control is unmistakable and invariant.  splitting
that across a function call seems like a dangerous thing to do.
(except, of course, in the case, where the kzalloc() is added inside
the function -- then all callers are entitled to simplify *their*
code.  but that's different.)

in any event, i just thought i'd point it out.  if you're absolutely
sure there will never be another call to setup_dev() from somewhere
else, then, yes, it's safe.

rday

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================
