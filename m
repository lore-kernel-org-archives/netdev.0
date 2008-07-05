From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Sat, 05 Jul 2008 00:35:52 -0400
Message-ID: <486EFA28.9040105@garzik.org>
References: <1215093175.10393.567.camel@pmac.infradead.org> <20080703173040.GB30506@mit.edu> <1215111362.10393.651.camel@pmac.infradead.org> <20080703.162120.206258339.davem@davemloft.net> <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org> <1215177044.10393.743.camel@pmac.infradead.org> <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org> <486E2818.1060003@garzik.org> <20080704143058.GB23215@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Theodore Tso <tytso@mit.edu>,
	David Woodhouse <dwmw2@infradead.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hugh@veritas.com,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51614 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959AbYGEEgN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jul 2008 00:36:13 -0400
In-Reply-To: <20080704143058.GB23215@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Theodore Tso wrote:
> On Fri, Jul 04, 2008 at 09:39:36AM -0400, Jeff Garzik wrote:
>> You have been told repeatedly that cp(1) and scp(1) are commonly used to  
>> transport the module David and I care about -- tg3.  It's been a single  
>> file module since birth, and people take advantage of that fact.
> 
> Here, I think I'll have to respectly disagree with you and say that
> you are taking things too far.  I don't think scp'ing individual
> modules around counts as an "exported user interface" the same way,
> say "make install; make modules_install" is a commonly understand and
> used interface by users and scripts (i.e., such as Debian's make-kpkg,
> which does NOT know about "make firmware_install", BTW).

It's not just netdev developers that use that method, root (notably 
router) image and driver disk build scripts use it too.  They've been 
able to skate around module dependencies because network drivers rarely 
have module dependencies or require big multi-module systems.

Example -- the driver disk kit that RH informally gave out, which was 
widely used, but does not use normal kernel build processes:

	http://people.redhat.com/dledford/mod_devel_kit.tgz

Even if one modifies 'make modules_install' as discussed[1], kits like 
these will report "100% success! driver disk created", yet ship a dead 
driver disk.

That is why putting the firmware in the kernel image, as dwmw2 has done, 
does not fix regressions here:  driver disk authors do not necessarily 
have the luxury of updating the kernel.

Conclusion - we should not build a system today that /excludes/ the 
possibility of building drivers as they are built today -- with the 
firmware inside the module [if CONFIG_FOO=m] or kernel image [if 
CONFIG_FOO=y].

That is the only path that gives everyone a chance to deal with this 
transition.

	Jeff





[1] a laudable and useful thing to do, and it sounds like it is being 
accomplished.  great!

