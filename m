From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH] proc_fs.h redux
Date: Mon, 29 Oct 2007 11:03:04 -0200
Message-ID: <20071029130304.GA7810@ghostprotocols.net>
References: <20071027194758.GD9816@martell.zuzino.mipt.ru> <1193524804.26695.103.camel@localhost> <20071028084441.GA24221@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	Alexey Dobriyan <adobriyan@gmail.com>, akpm@osdl.org,
	torvalds@osdl.org, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arch@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:65486 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279AbXJ2NDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 09:03:18 -0400
Received: by an-out-0708.google.com with SMTP id b36so201155ana
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 06:03:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20071028084441.GA24221@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Sun, Oct 28, 2007 at 09:44:41AM +0100, Sam Ravnborg escreveu:
> > 
> > As a general rule, I think it better to use includes
> > than use naked forward declarations.
> 
> Quite the opposite - at least in the kernel source.
> The general rule is that a .h file shall include the
> .h files which contain declarations used by said .h files.
> But naked declarations as above is preferred over including
> a full header file.

yup
 
> We see the full header dependency thing to blow off when
> inline function are used - which is more and more the case.
> In several cases we have converted inline functions to macros
> just to simplify the nightmare of header dependencies we have.
> 
> Arnaldo have a nice script that generate a .ps file
> showing all the dependencies.
> He lately posted this URL: http://oops.ghostprotocols.net:81/acme/tcp.h.ps

Well, not "lately", it has been quite a while. But lets celebrate the
fact that there is somebody trying to fight this battle one more time
and update this tcp.h dependency tree... /me looks for hviz... and if
graphviz is installed, ok:

http://www.kernel.org/pub/linux/kernel/people/acme/hviz

hviz include/linux/tcp.h 10 | dot -Tpdf > /tmp/tcp.h.2007_11.pdf

http://oops.ghostprotocols.net:81/acme/tcp.h.2007_11.pdf

We still get to sched.h, but before it was:

linux/tcp.h -> linux/skbuff.h -> linux/mm.h -> linux/sched.h

Nowadays its:

linux/tcp.h -> linux/sock.h -> linux/netdevice.h -> linux/interrupt.h -> linux/sched.h

And I just removed "#include <linux/sched.h> from linux/interrupt.h,
because as far as I checked it is completely unnecessary, and the
kernel builds just fine :-)

- Arnaldo
