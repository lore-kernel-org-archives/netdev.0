From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 3.11-rc regression bisected: s2disk does not work (was Re: [PATCH
 v3 13/16] futex: use freezable blocking call)
Date: Mon, 22 Jul 2013 17:32:48 -0700
Message-ID: <CA+55aFzUVPJe96z8V0F-znc8ZcpJid7LEeYww80M-Mx=S91tAA@mail.gmail.com>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
	<1367884221-20462-14-git-send-email-ccross@android.com>
	<20130723010250.5a3465ec@xenia.leun.net>
	<CAMbhsRQv+W897_5qGuNJD47jQ9ozN6KxeCa6UJAvZpqVuBpQ4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Leun <lkml20130126@newton.leun.net>,
	lkml <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	linux-nfs <linux-nfs@vger.kernel.org>,
	Linux PM list <linux-pm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
	Darren Hart <dvhart@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Randy Dunlap <rdunlap@infradead.org>,
	Al Viro <viro@zeniv.linux.org.uk>
To: Colin Cross <ccross@android.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <CAMbhsRQv+W897_5qGuNJD47jQ9ozN6KxeCa6UJAvZpqVuBpQ4w@mail.gmail.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 22, 2013 at 4:55 PM, Colin Cross <ccross@android.com> wrote:
>
> I think the right solution is to add a flag to the freezing task that
> marks it unfreezable.  I  think PF_NOFREEZE would work, although it is
> normally used on kernel threads, can you see if the attached patch
> helps?

Hmm. That does seem to be the right thing to do, but I wonder about
the *other* callers of freeze_processes() IOW, kexec and friends.

So maybe we should do this in {freeze|thaw}_processes() itself, and
just make the rule be that the caller of freeze_processes() itself is
obviously not frozen, and has to be the same one that then thaws
things?

Colin? Rafael? Comments?

                Linus
