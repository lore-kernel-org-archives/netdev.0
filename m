From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Y2038] [RESEND PATCH 2/3] fs: poll/select/recvmmsg: use timespec64 for timeout events
Date: Wed, 04 May 2016 23:08:11 +0200
Message-ID: <4256673.7Gok2HNpOM@wuerfel>
References: <1461947989-21926-3-git-send-email-deepa.kernel@gmail.com> <1462389899-2480-1-git-send-email-deepa.kernel@gmail.com> <CALAqxLVB8XiRrFKxK3GzBxw-CfEmC=Dh-CrTOEqT144ngZg-Dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: John Stultz <john.stultz@linaro.org>,
	Deepa Dinamani <deepa.kernel@gmail.com>,
	netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Oleg Nesterov <oleg@redhat.com>
To: y2038@lists.linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALAqxLVB8XiRrFKxK3GzBxw-CfEmC=Dh-CrTOEqT144ngZg-Dw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 04 May 2016 13:04:37 John Stultz wrote:
> On Wed, May 4, 2016 at 12:24 PM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
> > struct timespec is not y2038 safe.
> > Even though timespec might be sufficient to represent
> > timeouts, use struct timespec64 here as the plan is to
> > get rid of all timespec reference in the kernel.
> >
> > The patch transitions the common functions:
> > poll_select_set_timeout() and select_estimate_accuracy()
> > to use timespec64. And, all the syscalls that use these
> > functions are transitioned in the same patch.
> >
> > The restart block parameters for poll uses monotonic time.
> > Use timespec64 here as well to assign timeout value. This
> > parameter in the restart block need not change because
> > this only holds the monotonic timestamp at which timeout
> > should occur. And, unsigned long data type should be big
> > enough for this timestamp.
> >
> > The system call interfaces will be handled in a separate
> > series.
> >
> > Compat interfaces need not change as timespec64 is an
> > alias to struct timespec on a 64 bit system.
> >
> > Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: netdev@vger.kernel.org
> > ---
> > Resending to include John and Thomas on this patch as well.
> > This is to include this patch also in John's tree.
> > This will let all 3 patches in the series to merged through the same tree.
> >
> >  fs/eventpoll.c       | 12 +++++-----
> >  fs/select.c          | 67 +++++++++++++++++++++++++++++-----------------------
> >  include/linux/poll.h | 11 +++++----
> >  net/socket.c         |  8 ++++---
> >  4 files changed, 54 insertions(+), 44 deletions(-)
> 
> 
> So with the other two patches, I'm more comfortable queueing and
> sending through to Thomas.

Note that of course patch 3 depends on patch 2, otherwise it would
be a simple rename.

> But I'm less comfortable making the call on this one. It looks
> relatively straight forward, but it would be good to have maintainer
> acks before I add it to my tree.

Agreed. Feel free to add my

Reviewed-by: Arnd Bergmann <arnd@arndb.de>

at least (whoever picks it up). The file hasn't changed much in the past
decade, these are all the people who did more than 1 patch for fs/select.c
in git history:

      7 Al Viro
      6 Eliezer Tamir
      6 Arjan van de Ven
      4 Andrew Morton
      3 Linus Torvalds
      3 Heiko Carstens
      2 Vadim Lobanov
      2 Roland McGrath
      2 Oleg Nesterov
      2 Jiri Slaby
      2 Guillaume Knispel
      2 Eric Dumazet
      2 Dipankar Sarma
      2 Alexey Dobriyan

adding a few more to Cc, maybe someone else finds the time to take a
second look.

	Arnd
