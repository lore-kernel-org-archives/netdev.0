From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: Re: SOMAXCONN too low
Date: Wed, 29 Oct 2003 09:13:44 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16287.62792.721035.910762@napali.hpl.hp.com>
References: <200310290658.h9T6w04k015302@napali.hpl.hp.com>
	<20031029133315.5638f842.ak@suse.de>
Reply-To: davidm@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidm@hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031029133315.5638f842.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> On Wed, 29 Oct 2003 13:33:15 +0100, Andi Kleen <ak@suse.de> said:

  Andi> On Tue, 28 Oct 2003 22:58:00 -0800
  Andi> David Mosberger <davidm@napali.hpl.hp.com> wrote:

  >> Also, it appears that current SuSE kernels do indeed have a
  >> net.core.somaxconn sysctl to let a sysadmin choose a larger SOMAXCONN
  >> value.

  Andi> Yes I did that patch some time ago for some server who needed
  Andi> it. If there is interest I can submit it for 2.6. But I'm not
  Andi> sure it fits the "important bug fixes only" rule.

Yes, I think the patch should be (re-)submitted.  It certainly fixes a
performance bug.  At the moment, in-kernel servers are at an unfair
advantage over user-space servers for this reason.

In my opinion, SOMAXCONN should also be bumped, but that's less
critical if there is a sysctl to override the default value (plus I
only have a hand-wavy argument as to what SOMAXCONN should be...).

Another argument _for_ including the patch in 2.6.0 is so that we
don't have to add a user-visible change in the middle of 2.6 (e.g.,
simplifies documentation etc).  Plus the patch is trivial.

  Andi> Another alternative would be to make it a fraction of the
  Andi> listen() argument per socket
  Andi> (e.g. min(tcp_max_syn_backlog,min(128,10%*listenarg))) to
  Andi> allow the application to easily change it.

I don't understand what purpose this would serve.  Seems to me it
would make life only more complicated for apps that know what they're
doing.

	--david
