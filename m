From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: Re: SOMAXCONN too low
Date: Wed, 29 Oct 2003 10:08:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16288.537.258222.601897@napali.hpl.hp.com>
References: <200310290658.h9T6w04k015302@napali.hpl.hp.com>
	<20031029133315.5638f842.ak@suse.de>
	<16287.62792.721035.910762@napali.hpl.hp.com>
	<20031029092220.12518b68.davem@redhat.com>
Reply-To: davidm@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidm@hpl.hp.com, ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031029092220.12518b68.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> On Wed, 29 Oct 2003 09:22:20 -0800, "David S. Miller" <davem@redhat.com> said:

  DaveM> On Wed, 29 Oct 2003 09:13:44 -0800 David Mosberger
  DaveM> <davidm@napali.hpl.hp.com> wrote:

  >> >>>>> On Wed, 29 Oct 2003 13:33:15 +0100, Andi Kleen <ak@suse.de>
  >> said:

  Andi> Another alternative would be to make it a fraction of the
  Andi> listen() argument per socket
  Andi> (e.g. min(tcp_max_syn_backlog,min(128,10%*listenarg))) to
  Andi> allow the application to easily change it.
  >>  I don't understand what purpose this would serve.  Seems to me
  >> it would make life only more complicated for apps that know what
  >> they're doing.

  DaveM> Andi's saying the the max backlog should be a function of the
  DaveM> queue length the user asks for when he makes the listen()
  DaveM> system call.

Sure, but I just don't see the point of doing that.

  DaveM> Also note that we'll need to tweak the TCP listening socket
  DaveM> SYNQ hash table size if we modify these kinds of things.

Perhaps, but is this really a first-order effect?  Since it won't
affect user-level, perhaps that could be done a bit later?  (In the
interest of minimizing 2.6.0 patch, I mean.)

  >> At the moment, in-kernel servers are at an unfair advantage over
  >> user-space servers for this reason.

  DaveM> I totally disagree, the only reason things like TuX perform
  DaveM> better than their userland counterparts and don't run into
  DaveM> SOMAXCONN issues is because it is threaded properly.  This is
  DaveM> where all of the "jitter" stuff you keep talking about really
  DaveM> comes from.

We noticed this problem with a server that uses one thread per CPU
(pinned).  Why don't you run tux with the "backlog" parameter set to
128 and see what happens under heavy load?

	--david
