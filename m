From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Wed, 25 May 2011 14:47:41 +0200
Message-ID: <20110525124741.GC29300@elte.hu>
References: <m11uzrvd26.fsf@fess.ebiederm.org>
 <BANLkTim4q5dK6nOb=pVKbk1c8b-Nh_hBfA@mail.gmail.com>
 <m1boyvpo9r.fsf@fess.ebiederm.org>
 <1306048393.4092.8.camel@mulgrave.site>
 <20110522084224.GA12279@elte.hu>
 <m1k4dgr35i.fsf@fess.ebiederm.org>
 <20110524071628.GA31612@elte.hu>
 <4508.1306283693@localhost>
 <20110525082514.GE21552@elte.hu>
 <BANLkTikVDrU7Nx6143gPuB=1vwqkMFiRiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Valdis.Kletnieks@vt.edu,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTikVDrU7Nx6143gPuB=1vwqkMFiRiQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Geert Uytterhoeven <geert@linux-m68k.org> wrote:

> > But at least the primary, 'native' syscall table of every arch 
> > could be kept rather fresh via generic enumeration.
> 
> So we can start all over at offset 501 (alpha just started using 
> 500) with a unified, clean, and compressed list of syscalls? Or do 
> we have some more other-os-compat syscalls around in this range?

No, that would leave a big hole in the syscall table of most 
architectures.

So what would be needed is for each architecture to define a 'generic 
syscall table base index', ARCH_SYSCALL_BASE or so, and the generic 
syscalls would be added for that.

Alpha would have 501, the others lower numbers.

The only general assumption we can rely on is that there's a range of 
not yet used syscall numbers starting at the end of the current 
syscall table.

Thanks,

	Ingo
