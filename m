From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [1/6] 2.6.21-rc2: known regressions
Date: Sun, 4 Mar 2007 18:26:19 -0800
Message-ID: <20070304182619.6110bd74.akpm@linux-foundation.org>
References: <Pine.LNX.4.64.0702272105220.12485@woody.linux-foundation.org>
	<20070305015031.GF3441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Ayaz Abdulla <aabdulla@nvidia.com>, Pavel Machek <pavel@ucw.cz>,
   Garzik <jeff@garzik.org>, Jeff@smtp.osdl.org,
   Marcel Holtmann <marcel@holtmann.org>, Matt Mackall <mpm@selenic.com>,
   linux-pm@lists.osdl.org, List <linux-kernel@vger.kernel.org>,
   Sid Boyce <g3vbv@blueyonder.co.uk>, netdev@vger.kernel.org,
   bluez-devel@lists.sourceforge.net, maxk@qualcomm.com, Linux@smtp.osdl.org,
   Mark Lord <lkml@rtr.ca>, Johannes Berg <johannes@sipsolutions.net>,
   Linus Torvalds <torvalds@linux-foundation.org>,
   Albert Hopkins <kernel@marduk.letterboxes.org>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <linux-pm-bounces@lists.osdl.org>
In-Reply-To: <20070305015031.GF3441@stusta.de>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Mar 2007 02:50:31 +0100 Adrian Bunk <bunk@stusta.de> wrote:

> This email lists some known regressions in 2.6.21-rc2 compared to 2.6.20
> that are not yet fixed in Linus' tree.


We seem to have broken an unusually large amount of stuff this time.

partial post-mortem:

- The ACPICA merge landed in -mm super-late: basically it was in mainline
  a week afterwards and saw only a single -mm release.

  Part of the reason for this short period in -mm was that ACPICA had its
  paws all over x86_64 code and conflicted badly with significant changes
  in the x86_64 tree.

  That happens sometimes.  But when it does, the mess lands in my lap
  rather than in the laps of the perpetrators.

  Lesson: keep the code well-factored so that different subsystems don't
  soil each others' kennels.

- The hrtimers/dynticks stuff is simply hard: timekeeping, low-level x86,
  even APICs.  These are areas in which things break a lot, so churning it
  was inevitably going to cause problems.

  Lesson: none, I think.  Low-level x86 support is just hard, and
  changing it breaks things.


So that accounts for _some_ of the damage, but I wonder if there's more to
it than that.
