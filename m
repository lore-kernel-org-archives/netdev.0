From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Tue, 20 Mar 2007 09:52:42 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703200947501.6730@woody.linux-foundation.org>
References: <20070319.120854.30182994.davem@davemloft.net>
	<20070319.204712.118947830.davem@davemloft.net>
	<m13b40wnrb.fsf@ebiederm.dsl.xmission.com>
	<200703201428.50564.ak@suse.de>
	<m1ircvswzz.fsf@ebiederm.dsl.xmission.com>
	<20070320174159.GA4286@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org, mingo@elte.hu,
   linux-kernel@vger.kernel.org, jbeulich@novell.com,
   virtualization@lists.linux-foundation.org, chrisw@sous-sol.org,
   virtualization@lists.osdl.org, "Eric W. Biederman" <ebiederm@xmission.com>,
   anthony@codemonkey.ws, akpm@linux-foundation.org,
   David Miller <davem@davemloft.net>
To: Andi Kleen <ak@suse.de>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20070320174159.GA4286@bingen.suse.de>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On Tue, 20 Mar 2007, Andi Kleen wrote:
> =

> No, me and Jan fixed all reported bugs as far as I know.

No you did not. You didn't fix the ones I reported. Which is why it got =

removed, and will not get added back until there is another maintainer.

The ones I reported were all about trusting the stack contents implicitly, =

and assuming that the unwind info was there and valid. Using things like =

"__get_user()" didn't fix it, because if a WARN_ON() happened while we =

held the mm semaphore and the unwind info was bogus, it would take a =

page-fault and deadlock.

Those kinds of things are not acceptable for debugging output. If I cannot =

use WARN_ON() because I hold the MM lock and I'm afraid there might be =

kernel corruption, then something is *wrong*!

And I told you guys this. Over *months*. And you ignored me. You told me =

everything was fine. Each time, somebody else ended up reporting a hang =

where the unwinder was at fault. And since I couldn't trust the =

maintainers to fix it, removing the broken feature that only caused more =

problems than it fixed was the only option.

And you clearly *still* haven't accepted the fact that the code was buggy. =


Does anybody wonder why I wouldn't merge it back?

		Linus
