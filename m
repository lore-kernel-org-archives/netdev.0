From: Andres Salomon <dilinger@queued.net>
Subject: [PATCH 0/9] OLPC: create a generic OLPC EC driver
Date: Wed, 18 Jul 2012 21:21:40 -0700
Message-ID: <20120718212140.2e538301@dev.queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paul Fox <pgf@laptop.org>, Daniel Drake <dsd@laptop.org>,
	"Richard A. Smith" <richard@laptop.org>,
	linux-kernel@vger.kernel.org, libertas-dev@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, devel@driverdev.osuosl.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Dan Williams <dcbw@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Matthew Garrett <mjg@redhat.com>,
	Anton Vorontsov <cbou@mail.ru>,
	David Woodhouse <dwmw2@infradead.org>,
	Chris Ball <cjb@laptop.org>,
	Jon Nettleton <jon.nettleton@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The OLPC EC (Embedded Controller) code that is currently upstream is
x86-only, originally written for the XO-1.  Since then, we've had the
XO-1.5 (also x86), and XO-1.75 (arm-based) enter mass production.  The
1.75 uses a vastly different EC protocol, and future hardware revisions
are likely to change it even further.

However, the drivers do share quite a bit of code, so it makes sense to
have a platform-agnostic driver that calls into platform-specific hooks
for each XO's EC driver.  This is the first stab and creating such a
beast (with further patches pending).  Aside from the lack of code
duplication, this is helpful for fixing bugs in one place (for example,
we fixed an EC suspend/resume bug in 1.75 that I've just seen happen on
1.5 without these patches.  With these patches, the problem goes away).

These patches are against Linus's current HEAD; let me know if they
don't apply somewhere, and I'll happily redo them against the -next
tree.  I'm assuming that these changes (which touch places like x86,
wireless, and staging) should go through either the x86 tree, or
through akpm's tree.

Alternatively, if the reviews are positive and I can get SOBs from the
relevant maintainers, I can set up a platform-olpc tree somewhere and
request a pull from Linus.
