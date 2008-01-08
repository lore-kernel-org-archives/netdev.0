From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Tue, 8 Jan 2008 10:08:31 -0800 (PST)
Message-ID: <alpine.LFD.1.00.0801080957280.3148@woody.linux-foundation.org>
References: <477FF149.4070609@linux.intel.com> <20080105213935.GN27894@ZenIV.linux.org.uk> <20080107174431.GC27741@fieldses.org> <4782CF9C.6000508@gmail.com> <alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org> <20080108081401.d9576ac5.randy.dunlap@oracle.com>
 <4783B602.1050307@linux.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Kevin Winchester <kjwinchester@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55649 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751777AbYAHSKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 13:10:55 -0500
In-Reply-To: <4783B602.1050307@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 8 Jan 2008, Arjan van de Ven wrote:
> 
> I've made life easier for those using the www.kerneloops.org website;
> at least for x86 oopses the website now does this for you and shows
> the decoded Code: line in the raw oops data:
> 
> http://www.kerneloops.org/raw.php?rawid=2716

Cool.

One thing I wonder about - could you separate out the bug-ons and warnings 
from the oopses? They really are different issues, and an oops with 
register information etc is very different from a BUG() with line numbers, 
which in turn is very different from a WARN_ON().

Right now, it says

	Oopses reported for kernel 2.6.24-rc7


	7 oopses reported

	hfsplus_releasepage	3
	enqueue_task		1
	lock_acquire		1
	__hfs_brec_find		1
	__ieee80211_rx		1

and in fact three of those five entries are really WARN_ON's. It would be 
nicer if it would look more along the lines of

	Backtraces reported for kernel 2.6.24-rc7


	4 oopses reported

	hfsplus_releasepage     3
	__hfs_brec_find         1


	3 warnings repored

	enqueue_task            1
	lock_acquire            1
	__ieee80211_rx          1

because those things really don't have the same kind of impact at all, and 
tend to be very different to debug (a "BUG_ON()" is perhaps somewhat 
closer to an oops, but a WARN_ON() is definitely in a class of its own).

On that "Code:" side, it seems there is still some problem with oops 
parsing. See for example:

	http://www.kerneloops.org/raw.php?rawid=1521&msgid=http://mid.gmane.org/20071017154655.GA13394@elte.hu

and notice how the Code: never made it into the raw message (and thus 
there is also no instruction disassembly).

			Linus
