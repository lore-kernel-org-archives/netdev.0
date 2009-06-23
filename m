From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v3.1415] Documentation: add documentation summary for
 rc-series and merge window
Date: Tue, 23 Jun 2009 12:04:54 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0906231156220.3240@localhost.localdomain>
References: <20090622222217.GH23972@bombadil.infradead.org> <m3fxdqj2bz.fsf@lwn.net> <m3bpoen5pp.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jake Edge <jake@lwn.net>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Pavel Machek <pavel@ucw.cz>, Greg KH <greg@kroah.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tshibata@ab.jp.nec.com" <tshibata@ab.jp.nec.com>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46209 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751071AbZFWTFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 15:05:43 -0400
In-Reply-To: <m3bpoen5pp.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 23 Jun 2009, Krzysztof Halasa wrote:
> 
> I would say, to address regressions and fix bugs. Not only those added
> recently, though obviously older bugs should have already been fixed.

The thing is, I don't take bug fixes late in the -rc just because they are 
bug fixes.

And I really shouldn't.

If it's an old bug, and doesn't cause an oops or a security issue, it had 
damn well better wait for the next merge window. There is absolutely _no_ 
reason to just blindly "fix bugs" at the end of the rc stage, because 
quite frankly, the risks coming from fixing a bug is often bigger than the 
advantage.

Even "obvious bugs" may be things that people depend on, or that other 
parts of the kernel simply rely on indirectly. For a recent example of 
this, see what happened when we fixed an obvious bug on x86-64 to check 
user space addresses properly: it turns out that 'strnlen_user()' depended 
on the bug ("misfeature"), and had to be fixed when the bug was fixed.

So no. Regressions really are _different_ from "fixing bugs".

Regressions need to be fixed even if it may even re-introduce another 
long-time bug - simply because we're much better off with a _consistent_ 
set of bugs where people can depend on their machine either working or 
not, than with some kind of unstable situation that never gets anywhere 
(we found that out the hard way with both ACPI and power management).

So the end result is:

 - we always want to fix bugs

 - but the primary time to fix bugs is during the merge window

 - after the merge window closes, the effort should be on _regressions_, 
   nothing else.

 - security issues and oopses etc catastrophic bugs obviously need to be 
   handled at any stage.

IOW, "it fixes a bug" is _not_ sufficient. The real issue is "it _really_ 
can't wait to the next merge window", not "bug or not".

				Linus
