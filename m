From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Wed, 8 Aug 2007 09:21:14 +0200
Message-ID: <20070808072114.GA1731@ff.dom.local>
References: <JMEYNL$38C71F6F1D25A7CE82B12729A59CF244@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cebbert <cebbert@redhat.com>, mingo <mingo@elte.hu>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	tglx <tglx@linutronix.de>,
	torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Jean-Baptiste Vignaud <vignaud@xandmail.fr>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <JMEYNL$38C71F6F1D25A7CE82B12729A59CF244@xandmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 07, 2007 at 07:16:33PM +0200, Jean-Baptiste Vignaud wrote:
...
> So this afternoon i compiled 2.6.23-rc2 with same options as 2.6.23-rc1
> and edited grub.conf to add nosmp but after reboot the box did not
> responded. Back home, i saw that the kernel failed because it was unable
> to find the partitions (mdadm failed, then LVM). After a few tests,
> removing nosmp let the kernel boot correctly. It seems that even the
> fedora provided kernels have the same behavior
> (well at least 2.6.22.1-41.fc7).

Sorry: it seems there is some implementation error or some modules
don't check CONFIG_SMP enough...

Of course testing this with smp should be precious too.
Only, after finding some problems, you should consider smp is quite
a new and complicated technology, at least regarding such old designs
as 3c905.

BTW: I didn't notice this yesterday, but your forcedeth uses new type
of irq handling (MSI), so it should explain why it's not affected.

Jean-Baptiste: I'm not sure how much of this testing you can afford?
If you can spare some time for this and your box isn't for
'production' it could be very precious to diagnose such reproducible
bug.

Then, I'd have a few suggestions (you could choose any of them) like:
- trying these last test patches prepared for Marcin, too (but only
with kernels 2.6.21 - 2.6.23-rc1),
- trying to find the last kernel version, which works for you:
Marcin has done this with successfully using the most professional
way: git bisect (which btw. I did learn yet), but, IMHO, it could be
very usable to try a "poor man's" bisect too older kernels like this:
2.6.18, so to try again this version of previos Fedora, but
preferably in "vanilla" version (there could be some problems if
something in your configs or hardware has changed); then if OK:
2.6.20; if OK 2.6.21-rc1 or -rc2 (there are usually heavy changes
in the beginning of a cycle); ithen try to jump forward or backward
around the middle of the range eg. -rc4. You should use each time the
same, current config and remember to 'make oldconfig' before make.

In my opinion it would be very precious even after some long time,
so there is no need to hurry and do this now. The most important:
if nothing has changed with your hardware in the meantime, you
should find 'the culprit' for sure.

But, if there are any problems about such testing, don't bother!
It could be really a lot of hard and maybe boring work.

If you would like to read something more about testing (then of
course my suggestions could occur invalid - I'm a very bad tester
myself...) you can try this:
http://www.stardust.webpages.pl/files/handbook/

If you would need some additional advice you can mail me privately
too (but my response could take a few days). Of course, if your find
something interresting I'd be glad to know about this, but let's be
honest - I'm not any authority about these drivers, so cc-ing a
maintainer should always be more usable.

Thanks,
Jarek P.

PS: it would be nice if you could fix your mail program on line
breaking (or try to do this manually).

