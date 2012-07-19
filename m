From: Andres Salomon <dilinger@queued.net>
Subject: [PATCH 0/9] OLPC: create a generic OLPC EC driver
Date: Wed, 18 Jul 2012 18:21:44 -0700
Message-ID: <20120718182144.2d7b0b50@dev.queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Daniel Drake <dsd@laptop.org>,
 libertas-dev@lists.infradead.org, Dan Williams <dcbw@redhat.com>,
 netdev@vger.kernel.org, Jon Nettleton <jon.nettleton@gmail.com>,
 x86@kernel.org, linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 platform-driver-x86@vger.kernel.org, "Richard A. Smith" <richard@laptop.org>,
 Paul Fox <pgf@laptop.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Anton Vorontsov <cbou@mail.ru>, "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>, Chris Ball <cjb@laptop.org>,
 David Woodhouse <dwmw2@infradead.org>, Ingo Molnar <mingo@redhat.com>,
 "John W. Linville" <linville@tuxdriver.com>, Matthew Garrett <mjg@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
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
