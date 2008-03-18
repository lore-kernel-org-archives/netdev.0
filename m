From: Andrew Morton <akpm@linux-foundation.org>
Subject: [Bug 10238] Re: [PATCH] Re: netconsole still hangs
Date: Tue, 18 Mar 2008 01:50:06 -0700
Message-ID: <20080318015006.3f0efb8e.akpm@linux-foundation.org>
References: <20080312235205.dcec2d35.akpm@linux-foundation.org>
	<20080314234749.GA10606@ami.dom.local>
	<20080317161222.0fb9dfc9.akpm@linux-foundation.org>
	<20080318080439.GA3965@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, rjw@sisk.pl,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45930 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751769AbYCRIul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 04:50:41 -0400
In-Reply-To: <20080318080439.GA3965@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Mar 2008 08:04:39 +0000 Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Mon, Mar 17, 2008 at 04:12:22PM -0700, Andrew Morton wrote:
> ...
> > I retested.  This patch doesn't appear to make anything worse, but the hang
> > is still there.  
> 
> Yes, but since this doesn't look like something very common, and we
> don't even know if this OOPS and the hangs are the same bug, there is
> needed more information e.g.:
> 
> - is it reproducible with e1000E only and no wlan?

Yes.  Both the machines I can reproduce this on have both E1000=y and
E1000E=y.  From the dmesg (below), one uses e1000 and the other uses
e1000e.  Both crash.  

http://userweb.kernel.org/~akpm/config-akpm2.txt
http://userweb.kernel.org/~akpm/dmesg-akpm2.txt

http://userweb.kernel.org/~akpm/config-t61p.txt
http://userweb.kernel.org/~akpm/dmesg-t61p.txt

I used to be able to reproduce the problems with a 2-way i386 e100 system,
but that seems to be fixed now, perhaps from David's revert.

I also used to be able to reproduce the problem on a one-way i386 e100
machine but that also seem to have gone away.

> - is there a possibility to check this with some other card
>   (even wlan while e1000E is off)?

err, dunno.  Perhaps I could try e1000 on the e1000e-using machine and vice
versa, but for that some PCI ID table hacking might be needed.

I cc'ed bugzilla on this thread.

> - could you add .config to the bugzilla report:
>   http://bugzilla.kernel.org/show_bug.cgi?id=10238

See above.

> - is it acceptable to send you some patches for debugging this?

As a last resort.  But it'd surely be better if a net developer could
reproduce this and do some work on it.  It's bog-trivial to reproduce here
and afaik nobody has even tried.  Perhaps you have...

service syslog stop
while true
do
	echo t > /proc/sysrq-trigger
done

and that's it.
